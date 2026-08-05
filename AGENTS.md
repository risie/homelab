# Homelab — Agent Context

## Goal
Build a secure home developer platform for learning DevSecOps and platform security engineering.
This lab runs on Proxmox → K3s. Services exposed via NodePort on the LAN for development.
Tailscale will be added later for secure remote access.

## Current Stack
| Service | Namespace | Purpose |
|---------|-----------|---------|
| Tailscale Operator | `tailscale` | Network boundary, MagicDNS, TLS (optional, not deployed yet) |
| Forgejo + Postgres | `forgejo` | Git hosting, CI/CD, repo mirror to Codeberg |
| Hermes | `hermes` | AI agent interface (configure provider via WebUI) |

## Architecture
```
K3s Cluster (Proxmox)
├── forgejo.cluster.local:30080   → Forgejo (Git + Actions)
└── hermes.cluster.local:30081    → Hermes (AI agent)

Internal: Hermes → forgejo-service.forgejo.svc.cluster.local:3000
```

## Rules for Agents
1. **No hardcoded secrets** — Use K8s Secrets with placeholders. Real values set at deploy time.
2. **NodePort for now** — Tailscale will replace this in a future iteration.
3. **Namespace per service** — One namespace per application.
4. **Kustomize only** — No Helm unless explicitly requested.
5. **Minimal permissions** — RBAC scoped to what's needed.
6. **Local-path PVCs** — Simple storage, migratable later.

## Deploy Order
```bash
kubectl apply -k applications/infrastructure/apps/forgejo/
kubectl apply -k applications/infrastructure/apps/hermes/

# Optional: deploy Tailscale operator when ready
kubectl apply -k applications/infrastructure/platform/tailscale/
```

## Before Deploy
Replace `CHANGE_ME_*` placeholders in:
- `applications/infrastructure/apps/forgejo/secret.yaml`
- `applications/infrastructure/platform/tailscale/secret.yaml` (when deploying Tailscale)

## Roadmap (Future Iterations)
- Tailscale operator for secure remote access (replaces NodePort)
- SOPS + Age for encrypted secrets in git
- ArgoCD for GitOps
- Authentik for SSO/OIDC
- Forgejo Actions runner for CI/CD
- Codeberg mirror workflow
- Network policies (default deny)
- OpenBao for secret rotation
