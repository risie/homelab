# Homelab — Agent Context

## Goal
Build a secure home developer platform for learning DevSecOps and platform security engineering.
This lab runs on Proxmox → K3s, with all access through Tailscale (no open LAN ports).

## Current Stack
| Service | Namespace | Purpose |
|---------|-----------|---------|
| Tailscale Operator | `tailscale` | Network boundary, MagicDNS, TLS |
| Forgejo + Postgres | `forgejo` | Git hosting, CI/CD, repo mirror to Codeberg |
| Hermes | `hermes` | AI agent interface (configure provider via WebUI) |

## Architecture
```
Tailscale (Tailnet only)
├── forgejo.<tailnet>.ts.net   → Forgejo (Git + Actions)
└── hermes.<tailnet>.ts.net    → Hermes (AI agent)
```

## Rules for Agents
1. **No hardcoded secrets** — Use K8s Secrets with placeholders. Real values set at deploy time.
2. **No open ports** — All ingress must use Tailscale annotation.
3. **Namespace per service** — One namespace per application.
4. **Kustomize only** — No Helm unless explicitly requested.
5. **Minimal permissions** — RBAC scoped to what's needed.
6. **Local-path PVCs** — Simple storage, migratable later.

## Deploy Order
```bash
kubectl apply -k applications/infrastructure/platform/tailscale/
kubectl apply -k applications/infrastructure/apps/forgejo/
kubectl apply -k applications/infrastructure/apps/hermes/
```

## Before Deploy
Replace `CHANGE_ME_*` placeholders in:
- `applications/infrastructure/apps/forgejo/secret.yaml`
- `applications/infrastructure/platform/tailscale/secret.yaml`

## Roadmap (Future Iterations)
- SOPS + Age for encrypted secrets in git
- ArgoCD for GitOps
- Authentik for SSO/OIDC
- Forgejo Actions runner for CI/CD
- Codeberg mirror workflow
- Network policies (default deny)
- OpenBao for secret rotation
