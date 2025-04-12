# Download image
resource "proxmox_virtual_environment_download_file" "debian_12_generic_image" {
  provider     = proxmox.prox-lab
  node_name    = var.prox-lab.node_name
  content_type = "iso"
  datastore_id = "local"
  file_name    = "debian-12-generic-amd64.img"

  url                = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
  checksum           = "afcd77455c6d10a6650e8affbcb4d8eb4e81bd17f10b1d1dd32d2763e07198e168a3ec8f811770d50775a83e84ee592a889a3206adf0960fb63f3d23d1df98af"
  checksum_algorithm = "sha512"
}

