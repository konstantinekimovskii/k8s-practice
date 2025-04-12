# Declare worker node(s) for kubernetes cluser
resource "proxmox_virtual_environment_vm" "k8s-worker" {
  count       = var.worker_count
  provider    = proxmox.prox-lab
  node_name   = var.prox-lab.node_name
  name        = "k8s-worker-${count.index + 1}"
  description = "Worker node for kubernetes cluster"
  tags        = ["k8s", "worker"]
  on_boot     = true

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  bios          = "ovmf"

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge = "vmbr0"
  }

  serial_device {
    device = "socket"
  }

  efi_disk {
    datastore_id = var.datastore
    file_format  = "raw"
    type         = "4m"
  }

  disk {
    datastore_id = var.datastore
    file_id      = proxmox_virtual_environment_download_file.debian_12_generic_image.id
    interface    = "scsi0"
    cache        = "writethrough"
    discard      = "on"
    ssd          = true
    size         = 32
  }

  boot_order = ["scsi0"]

  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }

  # https://forum.proxmox.com/threads/8-3-debian-12-cloud-init-expanded-disk-ovmf-kernel-panic-on-first-boot.160125/
  initialization {
    interface         = "scsi1"
    datastore_id      = var.datastore
    user_data_file_id = proxmox_virtual_environment_file.for-worker-node[count.index].id

    dns {
      domain  = var.vm_dns.domain
      servers = var.vm_dns.servers
    }

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}

resource "proxmox_virtual_environment_file" "for-worker-node" {
  count        = var.worker_count
  provider     = proxmox.prox-lab
  node_name    = var.prox-lab.node_name
  content_type = "snippets"
  datastore_id = "local"

  source_raw {
    data = templatefile("./cloud-init/worker-node-cfg.tftpl", {
      common-config = templatefile("./cloud-init/vms-common-cfg.tftpl", {
        hostname    = "k8s-worker-${count.index + 1}"
        username    = var.vm_user
        password    = var.vm_password
        pub-key     = var.host_pub-key
        k8s-version = var.k8s-version
        kubeadm-cmd = module.kubeadm-join.stdout
      })
    })
    file_name = "worker-node-${count.index + 1}-cfg.yaml"
  }
}

output "workers_ipv4_addresses" {
  depends_on = [proxmox_virtual_environment_vm.k8s-worker]
  value = {
    for idx, vm in proxmox_virtual_environment_vm.k8s-worker :
    "worker-${idx + 1}" => vm.ipv4_addresses[1][0]
  }
}

resource "local_file" "work-01-ip" {
  count           = var.worker_count
  content         = proxmox_virtual_environment_vm.k8s-worker[count.index].ipv4_addresses[1][0]
  filename        = "output/worker-${count.index + 1}-ip.txt"
  file_permission = "0644"
}
