variable "prox-lab" {
  description = "Proxmox server for creating a cluster"
  type = object({
    node_name = string
    endpoint  = string
    insecure  = bool
  })
}

variable "prox-lab_auth" {
  description = "Auth data for connecting to Proxmox"
  type = object({
    username  = string
    api_token = string
  })
  sensitive = true
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
}

variable "vm_dns" {
  description = "DNS config for VMs"
  type = object({
    domain  = string
    servers = list(string)
  })
}

variable "datastore" {
  description = "Datastore for VMs disks"
  type        = string
}

variable "vm_user" {
  description = "VM username"
  type        = string
}

variable "vm_password" {
  description = "VM password"
  type        = string
  sensitive   = true
}

variable "host_pub-key" {
  description = "Host public key"
  type        = string
}

variable "k8s-version" {
  description = "Kubernetes version"
  type        = string
}

variable "cilium-cli-version" {
  description = "Cilium CLI version"
  type        = string
}
