#!/bin/bash

while [ ! -f /etc/rancher/k3s/config.yaml ]; do
  sleep 2
done

echo "starting K3s-installation..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="${cluster_init ? "server" : "agent"}" sh -

echo "K3s install finished" > /tmp/cloud-config.done
