# Declare control plane VM for kubernetes_cluster
resource "proxmox_virtual_environment_vm" "k8s-control-node" {
  provider    = proxmox.prox-lab
  node_name   = var.prox-lab.node_name
  name        = "k8s-control-node"
  description = "Control plane node for kuber cluster"
  tags        = ["kuber", "control-plane", "test"]
  on_boot     = true

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  bios          = "ovmf"

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 4096
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
    size         = 35
  }

  boot_order = ["scsi0"]

  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }

  initialization {
    interface         = "scsi1"
    datastore_id      = var.datastore
    user_data_file_id = proxmox_virtual_environment_file.for-ctrl-node.id
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

resource "proxmox_virtual_environment_file" "for-ctrl-node" {
  provider     = proxmox.prox-lab
  node_name    = var.prox-lab.node_name
  content_type = "snippets"
  datastore_id = "local" # The storage in which snippets is enabled

  source_raw {
    data = templatefile("./cloud-init/ctrl-node-cfg.tftpl", {
      common-config = templatefile("./cloud-init/vms-common-cfg.tftpl", {
        hostname    = "k8s-control-node"
        username    = var.vm_user
        password    = var.vm_password
        pub-key     = var.host_pub-key
        k8s-version = var.k8s-version
        kubeadm-cmd = "kubeadm init --skip-phases=addon/kube-proxy"
      })
      username           = var.vm_user
      cilium-cli-version = var.cilium-cli-version
      cilium-cli-cmd     = "HOME=/home/${var.vm_user} KUBECONFIG=/etc/kubernetes/admin.conf cilium install --set kubeProxyReplacement=true"
    })
    file_name = "ctrl-node-cfg.yaml"
  }
}

output "ctrl_node_ipv4_address" {
  depends_on = [proxmox_virtual_environment_vm.k8s-control-node]
  value      = proxmox_virtual_environment_vm.k8s-control-node.ipv4_addresses[1][0]
}

resource "local_file" "control-node-ip" {
  content         = proxmox_virtual_environment_vm.k8s-control-node.ipv4_addresses[1][0]
  filename        = "output/control-node-ip.txt"
  file_permission = "0644"
}

module "kube-config" {
  depends_on   = [local_file.control-node-ip]
  source       = "Invicton-Labs/shell-resource/external"
  version      = "0.4.1"
  command_unix = "ssh -o StrictHostKeyChecking=no ${var.vm_user}@${local_file.control-node-ip.content} cat /home/${var.vm_user}/.kube/config"
}

resource "local_file" "kube-config" {
  content         = module.kube-config.stdout
  filename        = "output/config"
  file_permission = "0600"
}

module "kubeadm-join" {
  depends_on   = [local_file.kube-config]
  source       = "Invicton-Labs/shell-resource/external"
  version      = "0.4.1"
  command_unix = "ssh -o StrictHostKeyChecking=no ${var.vm_user}@${local_file.control-node-ip.content} /usr/bin/kubeadm token create --print-join-command"
}
