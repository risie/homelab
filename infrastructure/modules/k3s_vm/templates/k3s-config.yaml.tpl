#cloud-config
write_files:
  - path: /etc/rancher/k3s/config.yaml
    owner: root:root
    permissions: "0600"
    content: |
      token: "${k3s_token}"
%{ if cluster_init }
      cluster-init: true
      write-kubeconfig-mode: "0644"
%{ else }
      server: "https://${server_ip}:6443"
%{ endif }
