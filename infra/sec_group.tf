# Default sec
resource "yandex_vpc_default_security_group" "common-sec-group" {
  description = "Группа по умолчанию"
  network_id  = yandex_vpc_network.sandbox-test-network.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "ANY"
    description    = "any internal"
    v4_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "198.18.235.0/24", "198.18.248.0/24", "169.254.169.254/32"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  
  ingress {
    protocol       = "TCP"
    description    = "web-app"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "web"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
  
  ingress {
    protocol       = "TCP"
    description    = "LB-in-kuber"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 30000
    to_port        = 61000
  }

}

# Common sec
resource "yandex_vpc_security_group" "k8s-sec-group" {
  name       = "k8s-sec-group"
  network_id = yandex_vpc_network.sandbox-test-network.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "ANY"
    description    = "any internal"
    v4_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "198.18.235.0/24", "198.18.248.0/24"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Unhandled Error"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }


  ingress {
    protocol       = "TCP"
    description    = "Unhandled Error"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

}
