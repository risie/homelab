#cloud-config
timezone: "UTC"
users:
  - default
  - name: "user"
    lock_passwd: true
    groups: [sudo]
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh_public_key}
    sudo: ALL=(ALL) NOPASSWD:ALL
  - name: root
    lock_passwd: true
packages:
  - qemu-guest-agent
  - curl
swap:
  filename: /swap.img
  size: 0
  maxsize: 0
runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - swapoff -a
