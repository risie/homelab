# Homelab — Agent Context

## Goal
Build a secure home developer platform for learning DevSecOps and platform security engineering.
Runs on Proxmox → single Ubuntu container host with Docker Compose.

## Current Stack
| Service | Purpose |
|---------|---------|
| Forgejo + Postgres | Git hosting, CI/CD, repo mirror to Codeberg |
| Hermes | AI agent interface (configure provider via WebUI) |
| Tailscale sidecars | HTTPS access via Tailscale Serve per service |

## Architecture
```
Proxmox
└── container-host (Ubuntu, 6 vCPU, 6GB RAM)
    ├── forgejo-db → forgejo → forgejo-tailscale (sidecar)
    └── hermes → hermes-tailscale (sidecar)

Internal: Hermes → http://forgejo:3000 (Docker DNS)
External: https://forgejo.<tailnet>.ts.net (Tailscale Serve)
```

## Rules for Agents
1. **No hardcoded secrets** — Use CHANGE_ME_* placeholders. Real values set at deploy time.
2. **Docker Compose only** — No Kubernetes, no Helm.
3. **Tailscale sidecars** — One sidecar per service, using Tailscale Serve for HTTPS.
4. **Named volumes** — Simple storage, easy to backup.
5. **Minimal configuration** — Get it working, refine later.

## Deploy Order
```bash
# SSH into container host
ssh ubuntu@$(tofu output -raw container_host_ip)

# Edit secrets
sudo nano /opt/homelab/docker-compose.yaml

# Start
cd /opt/homelab && docker compose up -d

# Auth sidecars
docker compose logs -f forgejo-tailscale
docker compose logs -f hermes-tailscale
```

## Before Deploy
Replace `CHANGE_ME_*` in `/opt/homelab/docker-compose.yaml`:
- `CHANGE_ME_FORGEJO_DB_PASS` — Postgres password
- `CHANGE_ME_FORGEJO_HOSTNAME` — Tailscale hostname
- `CHANGE_ME_TAILSCALE_AUTH_KEY` — Tailscale pre-auth key

## Roadmap (Future Iterations)
- SOPS + Age for encrypted secrets in git
- Forgejo Actions runner for CI/CD
- Codeberg mirror workflow
- Authentik for SSO/OIDC
- Network policies (Docker)
- OpenBao for secret rotation
