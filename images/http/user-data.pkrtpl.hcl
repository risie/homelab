#cloud-config
autoinstall:
  version: 1
  early-commands:
    - sudo systemctl stop ssh
  locale: ${vm_locale}
  keyboard:
    layout: ${vm_keyboard}
  network:
    network:
      version: 2
      ethernets:
        ens18:
          dhcp4: true
  storage:
    layout:
      name: direct
  identity:
    hostname: ${vm_hostname}
    username: ${vm_username}
    password: ${vm_password_hash}
  ssh:
    install-server: true
    allow-pw: true
  packages:
    - openssh-server
    - cloud-init
    - qemu-guest-agent
  user-data:
    disable_root: false
    timezone: ${vm_timezone}
  late-commands:
    - sed -i -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /target/etc/ssh/sshd_config
    - echo '${vm_username} ALL=(ALL) NOPASSWD:ALL' > /target/etc/sudoers.d/${vm_username}
    - curtin in-target --target=/target -- chmod 440 /etc/sudoers.d/${vm_username}
    - curtin in-target --target=/target -- systemctl enable qemu-guest-agent
