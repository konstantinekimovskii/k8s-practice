#cloud-config
ssh_pwauth: no
users:
- name: ${user}
  sudo: ALL=(ALL) NOPASSWD:ALL
  shell: /bin/bash
  ssh_authorized_keys:
  - ${public_key}
write_files:
  - path: "/usr/local/etc/startup.sh"
    permissions: "755"
    content: |
      #!/bin/bash
      apt update
      apt install -y ${packages}
    defer: true
runcmd:
  - ["/usr/local/etc/startup.sh"]