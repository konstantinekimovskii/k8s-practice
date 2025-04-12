# Service account (SA)
resource "yandex_iam_service_account" "k8s-sa" {
  name        = "k8s-sa"
  description = "k8s iam service account from IaC"
}

# Role for SA
resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = var.project-folder
  role      = "editor"
  members = [
    "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
  ]
}

# k8s regional cluster
resource "yandex_kubernetes_cluster" "k8s-regional-cluster" {
  name        = local.k8s_name
  description = "региональный кубер кластер для практики"
  network_id  = yandex_vpc_network.sandbox-test-network.id

  master {
    regional {
      region = "ru-central1"
      location {
        zone      = yandex_vpc_subnet.sandbox-public-subnet-a.zone
        subnet_id = yandex_vpc_subnet.sandbox-public-subnet-a.id
      }

      location {
        zone      = yandex_vpc_subnet.sandbox-public-subnet-b.zone
        subnet_id = yandex_vpc_subnet.sandbox-public-subnet-b.id
      }

      location {
        zone      = yandex_vpc_subnet.sandbox-public-subnet-d.zone
        subnet_id = yandex_vpc_subnet.sandbox-public-subnet-d.id
      }
    }

    version            = "1.30"
    public_ip          = true
    security_group_ids = ["${yandex_vpc_security_group.k8s-sec-group.id}"]

    maintenance_policy {
      auto_upgrade = true
    }

    master_logging {
      enabled                    = true
      kube_apiserver_enabled     = true
      cluster_autoscaler_enabled = true
      events_enabled             = true
      audit_enabled              = true
    }
  }

  release_channel         = "STABLE"
  service_account_id      = yandex_iam_service_account.k8s-sa.id
  node_service_account_id = yandex_iam_service_account.k8s-sa.id
  depends_on = [
    yandex_resourcemanager_folder_iam_binding.editor,
  ]
}

# k8s node group
resource "yandex_kubernetes_node_group" "k8s-node-group" {
  cluster_id = yandex_kubernetes_cluster.k8s-regional-cluster.id
  name       = "${local.k8s_name}-node-group"
  version    = "1.30"
  labels = {
    "env" = "test"
  }

  node_labels = {
    "gpu"      = "false"
    "regional" = "true"
  }

  instance_template {
    platform_id = "standard-v3"
    name        = "k8s-regional-node-{instance.index}-in-{instance.zone_id}"
    metadata = {
      "ssh-keys" = templatefile("${path.module}/meta/node-group.tpl", {
        user       = var.k8s_node_user
        public_key = var.k8s_public_key
      })
    }

    labels = {
      "env" = "test"
    }

    network_interface {
      nat = false
      subnet_ids = [
        "${yandex_vpc_subnet.sandbox-private-subnet-a.id}",
        "${yandex_vpc_subnet.sandbox-private-subnet-b.id}",
        "${yandex_vpc_subnet.sandbox-private-subnet-d.id}"
      ]
      security_group_ids = ["${yandex_vpc_default_security_group.common-sec-group.id}"]
    }

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      type = "network-ssd"
      size = 65
    }

    scheduling_policy {
      preemptible = true
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = 6
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
    }

    location {
      zone = "ru-central1-b"
    }

    location {
      zone = "ru-central1-d"
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

  }

  deploy_policy {
    max_expansion   = 1
    max_unavailable = 1
  }
}