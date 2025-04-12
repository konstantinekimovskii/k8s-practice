prox-lab = {
  node_name = "prox"
  endpoint  = "https://lab.local:8006/"
  insecure  = true
}

# Пользователь и его токен с дотаточным количеством ролей для создания ресурсов
prox-lab_auth = {
  username  = ""
  api_token = ""
}

# Хранилище для размещения дисков создаваемых VM
datastore = "local-lvm"

vm_dns = {
  domain  = "lab.local"
  servers = ["", ""]
}

vm_user      = ""
vm_password  = ""
host_pub-key = ""

# Количество узлов worker-нод
worker_count = 2

k8s-version        = "1.30"
cilium-cli-version = "0.18.3"