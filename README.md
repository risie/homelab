# Home Lab

A secure home developer platform for learning DevSecOps and platform security engineering.
Runs on Proxmox → K3s.

## Architecture

```
K3s Cluster (Proxmox)
├── forgejo.cluster.local:<nodeport>   → Forgejo (Git + Actions)
└── hermes.cluster.local:<nodeport>    → Hermes (AI agent)
```

Internal service communication uses K8s DNS (e.g., `forgejo-service.forgejo.svc.cluster.local:3000`).

## Project Structure

```
Homelab/
├── .gitignore
├── README.md
├── AGENTS.md
├── infrastructure/              # OpenTofu → K3s cluster on Proxmox
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── modules/
│   └── cloud-init/
└── applications/                # Kustomize manifests
    └── infrastructure/
        ├── platform/
        │   └── tailscale/       # Tailscale operator (optional, for later)
        └── apps/
            ├── forgejo/         # Git hosting + CI/CD
            └── hermes/          # AI agent interface
```

## Deploy Order

```bash
# 1. Provision K3s cluster on Proxmox
cd infrastructure
./quick-start.sh
tofu init && tofu apply

# 2. Deploy applications (replace CHANGE_ME_* in secrets first)
kubectl apply -k applications/infrastructure/apps/forgejo/
kubectl apply -k applications/infrastructure/apps/hermes/

# 3. (Optional) Deploy Tailscale operator when ready
kubectl apply -k applications/infrastructure/platform/tailscale/
```

## Access

Add to your hosts file (`/etc/hosts` or `C:\Windows\System32\drivers\etc\hosts`):

```
<node-ip> forgejo.cluster.local hermes.cluster.local
```

Then access:
- Forgejo: `http://forgejo.cluster.local:30080`
- Hermes: `http://hermes.cluster.local:30081`

Hermes reaches Forgejo internally via `http://forgejo-service.forgejo.svc.cluster.local:3000`.

## Infrastructure

K3s cluster on Proxmox using OpenTofu. Solves the "cloud-init too large" error by using minimal cloud-init configurations stored as Proxmox snippets.

- **4-node K3s cluster** (1 server + 3 agents)
- **Automated deployment** with OpenTofu
- **Static IP configuration** for all nodes

See [infrastructure/README.md](infrastructure/README.md) for details.

## Applications

| Service | Namespace | Access |
|---------|-----------|--------|
| Forgejo + Postgres | `forgejo` | forgejo.cluster.local:30080 |
| Hermes | `hermes` | hermes.cluster.local:30081 |
| Tailscale Operator | `tailscale` | Not deployed yet (optional) |
