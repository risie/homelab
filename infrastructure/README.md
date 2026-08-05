# Home Lab

A secure home developer platform for learning DevSecOps and platform security engineering.
Runs on Proxmox → single container host with Docker Compose.

## Architecture

```
Proxmox
└── container-host (Ubuntu 24.04, 6 vCPU, 6GB RAM)
    ├── Docker Compose
    │   ├── forgejo-db (Postgres 16)
    │   ├── forgejo (Git + Actions)
    │   ├── forgejo-tailscale (sidecar)
    │   ├── hermes (AI agent)
    │   └── hermes-tailscale (sidecar)
    └── Tailscale (host-level)
```

Tailscale sidecars expose each service with HTTPS via Tailscale Serve.
Forgejo and Hermes communicate internally via Docker network DNS.

## Project Structure

```
Homelab/
├── .gitignore
├── README.md
├── AGENTS.md
├── infrastructure/              # OpenTofu → container host VM on Proxmox
│   ├── main.tf
│   ├── cloud_init.tf
│   ├── images.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── templates/
│       ├── cloud-config.yaml.tpl   # Installs Docker, Compose, Tailscale
│       └── network-config.yaml.tpl
└── applications/                # (kept for reference, not used)
    └── infrastructure/
        ├── platform/
        │   └── tailscale/
        └── apps/
            ├── forgejo/
            └── hermes/
```

## Deploy

```bash
# 1. Provision container host
cd infrastructure
tofu init && tofu apply

# 2. SSH into the host
ssh ubuntu@$(tofu output -raw container_host_ip)

# 3. Edit placeholders in /opt/homelab/docker-compose.yaml
sudo nano /opt/homelab/docker-compose.yaml

# 4. Start services
cd /opt/homelab
docker compose up -d

# 5. Authenticate Tailscale sidecars (they will print auth URLs)
docker compose logs -f forgejo-tailscale
docker compose logs -f hermes-tailscale
```

## Access

After Tailscale sidecars authenticate, services are available at:
- Forgejo: `https://forgejo.<tailnet-name>.ts.net`
- Hermes: `https://hermes.<tailnet-name>.ts.net`

Internal service communication: `http://forgejo:3000` (Docker DNS)

## Infrastructure

Single Ubuntu VM on Proxmox using OpenTofu with cloud-init.

- **6 vCPU, 6GB RAM, 80GB disk**
- **Docker + Docker Compose** auto-installed
- **Tailscale** auto-installed (host + container sidecars)
- **DHCP** for simplicity (Tailscale handles access)

## Applications

| Service | Purpose | Access |
|---------|---------|--------|
| Forgejo + Postgres | Git hosting, CI/CD | Tailscale Serve HTTPS |
| Hermes | AI agent interface | Tailscale Serve HTTPS |

## Before First Deploy

Replace `CHANGE_ME_*` placeholders in `/opt/homelab/docker-compose.yaml`:

| Placeholder | What to put |
|-------------|-------------|
| `CHANGE_ME_FORGEJO_DB_PASS` | Strong password for Postgres |
| `CHANGE_ME_FORGEJO_HOSTNAME` | Tailscale hostname (e.g., `forgejo.tail1234.ts.net`) |
| `CHANGE_ME_TAILSCALE_AUTH_KEY` | Pre-auth key from Tailscale admin console |

## Backup

Only volumes that matter:

```bash
# Backup Forgejo data
docker compose cp forgejo:/data /backup/forgejo-data
docker compose cp forgejo-db:/var/lib/postgresql/data /backup/forgejo-db-data

# Backup Hermes data
docker compose cp hermes:/app/data /backup/hermes-data
```

## Roadmap (Future Iterations)

- SOPS + Age for encrypted secrets in git
- Forgejo Actions runner for CI/CD
- Codeberg mirror workflow
- Authentik for SSO/OIDC
- OpenBao for secret rotation
