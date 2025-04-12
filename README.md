# Kubernetes Practice Labs

Набор стендов для практики с Kubernetes и инфраструктурой как код (IaC). Каждый стенд разворачивает полноценный кластер с разными условиями (облако / on-prem) и предназначен для обучения, экспериментов и автоматизации.

## Стенды

### [Managed Kubernetes в Yandex.Cloud](labs/yandex-managed-k8s)

* Мультизональный кластер.
* NAT-инстанс, публичные control-plane ноды, приватные workers ноды.
* Terraform, Helm, kubectl, пример простого приложения.

### [Kubernetes кластер в Proxmox](labs/proxmox-k8s-cluster)

* Кластер из 2+ VM в Proxmox (1 control-plane + N workers).
* Cloud-init, Terraform, MetalLB, ingress-nginx.
* Локальный стенд для CICD, DevOps, тестов.

## ⚠️ Warning

Этот репозиторий создан в учебных целях и демонстрирует практику развёртывания и конфигурации Kubernetes-кластера.
Стенды не являются продакшн-решением и не имеют встроенной отказоустойчивости. Предназначены для запуска в лабораторной среде.
