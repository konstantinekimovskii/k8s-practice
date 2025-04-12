# Обзываем кластер
locals {
  k8s_name = "k8s-regional-cluster"
  nat      = "nat-node"
}

# id каталога YC в котором будем создавать стенд
variable "project-folder" {
  type    = string
  default = ""
}

# Определяем пользователя и его открытый ключ на NAT инстансе
variable "nat_user" {
  type    = string
  default = ""
}
variable "nat_public_key" {
  default = ""
}

# Определяем пользователя и его открытый ключ на нодах Kubernetes
variable "k8s_node_user" {
  type    = string
  default = ""
}
variable "k8s_public_key" {
  default = ""
}

# Установка дополнительных пакетов на NAT инстанс через cloud-init
variable "apt_packages" {
  default = "tmux"
}