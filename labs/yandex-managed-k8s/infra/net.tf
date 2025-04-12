# VPC
resource "yandex_vpc_network" "sandbox-test-network" {
  name = "sandbox-test-network"
}

# Public subnets for k8s-masters
resource "yandex_vpc_subnet" "sandbox-public-subnet-a" {
  name           = "sandbox-public-subnet-in-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.sandbox-test-network.id
  v4_cidr_blocks = ["172.16.0.0/26"]
}

resource "yandex_vpc_subnet" "sandbox-public-subnet-b" {
  name           = "sandbox-public-subnet-in-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.sandbox-test-network.id
  v4_cidr_blocks = ["172.16.0.64/26"]
}

resource "yandex_vpc_subnet" "sandbox-public-subnet-d" {
  name           = "sandbox-public-subnet-in-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.sandbox-test-network.id
  v4_cidr_blocks = ["172.16.0.128/26"]
}

# Private subnets for k8s-nodes
resource "yandex_vpc_subnet" "sandbox-private-subnet-a" {
  name           = "sandbox-private-subnet-in-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.sandbox-test-network.id
  v4_cidr_blocks = ["10.0.0.0/26"]
  route_table_id = yandex_vpc_route_table.route-for-private.id
}

resource "yandex_vpc_subnet" "sandbox-private-subnet-b" {
  name           = "sandbox-private-subnet-in-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.sandbox-test-network.id
  v4_cidr_blocks = ["10.0.0.64/26"]
  route_table_id = yandex_vpc_route_table.route-for-private.id
}

resource "yandex_vpc_subnet" "sandbox-private-subnet-d" {
  name           = "sandbox-private-subnet-in-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.sandbox-test-network.id
  v4_cidr_blocks = ["10.0.0.128/26"]
  route_table_id = yandex_vpc_route_table.route-for-private.id
}

# Default route for private sub's
resource "yandex_vpc_route_table" "route-for-private" {
  name       = "route-for-private"
  network_id = yandex_vpc_network.sandbox-test-network.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat-instance.network_interface.0.ip_address
  }
}

# NAT fot private sub's
data "yandex_compute_image" "latest_nat_image" {
  family    = "nat-instance-ubuntu-2204"
  folder_id = "standard-images"
}

resource "yandex_compute_disk" "boot-disk-nat" {
  name     = "boot-disk-nat"
  type     = "network-ssd"
  zone     = "ru-central1-b"
  size     = "35"
  image_id = data.yandex_compute_image.latest_nat_image.id
}

resource "yandex_compute_instance" "nat-instance" {
  name                      = "nat-instance"
  hostname                  = "nat-instance"
  platform_id               = "standard-v3"
  zone                      = "ru-central1-b"
  allow_stopping_for_update = true

  resources {
    core_fraction = 50
    cores         = 2
    memory        = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-nat.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.sandbox-public-subnet-b.id
    security_group_ids = [yandex_vpc_default_security_group.common-sec-group.id]
    nat                = true
  }

  metadata = {
    user-data = templatefile("${path.module}/meta/for-nat.tpl", {
      user       = var.nat_user
      public_key = var.nat_public_key
      packages   = var.apt_packages
    })
  }

  scheduling_policy {
    preemptible = true
  }
}
