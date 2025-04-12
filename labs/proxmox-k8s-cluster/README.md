# Kubernetes кластер в Proxmox

Пример развёртывания локального Kubernetes-кластера (1 control plane + N worker-нод) в Proxmox с использованием Terraform, cloud-init и kubeadm.

## Структура

* [**cloud-init/**](cloud-init/) — шаблоны cloud-init для настройки виртуальных машин:
  * `vms-common-cfg.tftpl` — общий для всех VM: пользователь, SSH, Docker, Kubernetes repo
  * `ctrl-node-cfg.tftpl` — для control-plane ноды
  * `worker-node-cfg.tftpl` — для worker нод(ы)

* [**services/**](services/) — вспомогательные манифесты Kubernetes:
  * `metallb-config.yaml` — IP-пул для MetalLB

* Основные Terraform-модули:
  * [**main.tf**](infra/main.tf) — подключение провайдера, proxmox аутентификация.
  * [**variables.tf**](infra/variables.tf) — описание необходимых переменных
  * [**variables.auto.tfvars**](infra/variables.auto.tfvars) — **значения переменных по умолчанию**
  * [**control-plane-node.tf**](infra/control-plane-node.tf) — описание control-plane ноды
  * [**worker-node.tf**](infra/worker-node.tf) — описание worker
  * [**os-disk.tf**](infra/os-disk.tf) — загрузка образа ОС

## Как развернуть

### Требования

* Установлены:
  * [Terraform](https://developer.hashicorp.com/terraform/install)
  * [kubectl](https://kubernetes.io/docs/tasks/tools/)
  * [Helm](https://helm.sh/docs/intro/install/)
* Настроенный Proxmox с API-доступом.

---

### Развёртывание инфраструктуры и кластера

```bash
cd labs/proxmox-k8s-cluster
terraform init
terraform apply --auto-approve
```
