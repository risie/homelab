# Homelab DevSecOps Platform - Implementation Roadmap

> **Vision**: Build a production-grade, self-hosted Kubernetes platform from scratch, learning DevSecOps practices through progressive implementation.

## 🎯 End Goal

A fully automated, security-hardened, self-sustaining platform that:
- Hosts real applications exposed to the internet
- Uses GitOps for all deployments
- Scans everything (code, containers, images)
- Monitors all components
- Treats infrastructure as cattle, not pets
- Demonstrates professional DevSecOps practices

## 📋 Guiding Principles

1. **Progressive Complexity** - Baby steps to monster
2. **Learn by Doing** - Hands-on at every phase
3. **Security First** - Baked in, not bolted on
4. **Production Patterns** - Real-world practices
5. **Overkill Mode** - Professional grade for homelab
6. **Understand Why** - Context for every decision
7. **Reference Worthy** - Documentation you'll return to

---

# Phase 0: Prerequisites & Planning

**Goal**: Understand the landscape and prepare your environment

**Duration**: 1-2 days

## What You Need

### Hardware
- [x] Proxmox host (or physical machine for Proxmox)
- [x] Minimum: 16GB RAM, 4 cores, 100GB storage
- [x] Recommended: 32GB RAM, 8 cores, 500GB storage
- [x] Optional: Old laptops/devices for physical nodes

### Accounts (Free Tier)
- [x] GitHub account (temporary bootstrap)
- [ ] Cloudflare account (for tunnels)
- [ ] Docker Hub account (temporary registry)

### Local Tools
- [x] OpenTofu/Terraform installed
- [x] kubectl installed
- [x] Git installed
- [x] SSH keys generated (`ssh-keygen`)

## Key Concepts to Understand

**Before starting, read about:**
- What is Kubernetes/K3s (15 min read)
- What is Infrastructure as Code (10 min read)
- What is GitOps (10 min read)
- What is immutable infrastructure (10 min read)

**You don't need to be an expert, just familiar with concepts.**

---

# Phase 1: Foundation - Manual Cluster

**Goal**: Get a working K3s cluster and deploy your first application

**Duration**: 1 week

**Why This Phase**: You need to understand Kubernetes basics before automating. Manual setup teaches you what's happening under the hood.

## What You'll Learn
- K3s installation and architecture
- Kubernetes fundamentals (pods, services, deployments)
- Networking basics
- How to expose services
- Cloudflare tunnel setup

## Prerequisites
- Proxmox installed and accessible
- Ubuntu cloud image template created
- Basic networking configured

## Steps

### 1.1: Create VMs Manually in Proxmox

**Goal**: 1 server + 2 agents

```bash
# Create from Ubuntu cloud template
# Server: 2 CPU, 4GB RAM, 192.168.1.100
# Agent1: 2 CPU, 4GB RAM, 192.168.1.101
# Agent2: 2 CPU, 4GB RAM, 192.168.1.102
```

**Why manual?** Learn the Proxmox UI, understand what Terraform will automate later.

### 1.2: Install K3s Server

```bash
ssh ubuntu@192.168.1.100
curl -sfL https://get.k3s.io | sh -s - server --write-kubeconfig-mode=644

# Get token for agents
sudo cat /var/lib/rancher/k3s/server/token
```

**What's happening**: K3s installs Kubernetes + dependencies in one command.

**Why K3s not K8s?** Simpler, less resource-intensive, perfect for learning.

### 1.3: Join Agents

```bash
# On each agent
ssh ubuntu@192.168.1.101
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.1.100:6443 K3S_TOKEN=<your-token> sh -
```

### 1.4: Verify Cluster

```bash
# On server
kubectl get nodes
# Should show 3 nodes in Ready state
```

**If this works: You have a Kubernetes cluster! 🎉**

### 1.5: Deploy First Application

```bash
# Simple nginx deployment
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get svc nginx
```

**Access it**: `http://192.168.1.100:<nodeport>`

**What you learned**: Kubernetes deploys and exposes applications.

### 1.6: Setup Cloudflare Tunnel

**Goal**: Expose nginx to the internet securely

```bash
# Install cloudflared
kubectl apply -f https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared.yaml

# Follow Cloudflare zero-trust tunnel setup
# Point to your nginx service
```

**What's happening**: Outbound tunnel, no open ports needed.

**Why Cloudflare?** Free, secure, no exposed ports.

## Validation

- [ ] 3 nodes showing Ready
- [ ] Nginx accessible locally
- [ ] Nginx accessible via Cloudflare tunnel
- [ ] You understand what each component does

## What You Achieved

✅ Working Kubernetes cluster
✅ First application deployed
✅ Application exposed to internet
✅ Foundation for automation

## Troubleshooting

**Nodes not Ready**: Check `kubectl describe node <name>`
**Can't access nginx**: Check service with `kubectl get svc`
**Cloudflare issues**: Check tunnel logs

---

# Phase 2: Infrastructure as Code

**Goal**: Automate cluster creation with Terraform/OpenTofu

**Duration**: 1-2 weeks

**Why This Phase**: Manual is fragile. IaC is repeatable, version-controlled, and foundational for GitOps.

## What You'll Learn
- Terraform/OpenTofu basics
- State management
- Variables and modules
- Resource dependencies
- Provisioners

## Prerequisites
- Phase 1 completed (understand what you're automating)
- OpenTofu installed locally
- Proxmox API token created

## Steps

### 2.1: Destroy Manual Cluster

```bash
# On each node
sudo /usr/local/bin/k3s-killall.sh

# In Proxmox, delete VMs
```

**Why?** Start fresh with automated approach.

### 2.2: Create Terraform Configuration

**Use the infrastructure code we created earlier in this conversation.**

```
infrastructure/
├── main.tf (VM definitions, K3s installation)
├── variables.tf (configurable parameters)
├── outputs.tf (cluster info)
├── terraform.tfvars (your values)
└── cloud-init/ (minimal startup configs)
```

**Why minimal cloud-init?** Avoids the 4KB limit, keeps fast.

### 2.3: Plan and Apply

```bash
cd infrastructure
tofu init
tofu plan    # Review what will be created
tofu apply   # Create cluster
```

**What's happening**: Terraform creates VMs, installs K3s, joins cluster - all automated.

### 2.4: Verify Cluster

```bash
# Get kubeconfig
scp ubuntu@192.168.1.100:/etc/rancher/k3s/k3s.yaml ./kubeconfig.yaml
sed -i 's/127.0.0.1/192.168.1.100/g' kubeconfig.yaml
export KUBECONFIG=$(pwd)/kubeconfig.yaml

kubectl get nodes
```

### 2.5: Deploy Application via Manifests

```bash
# Create deployment.yaml
kubectl apply -f deployment.yaml
```

**Why manifests?** Declarative, version-controlled, repeatable.

### 2.6: Test Destroy and Recreate

```bash
tofu destroy
tofu apply
```

**Goal**: Cluster rebuilds in ~10 minutes, exactly the same.

**This is cattle, not pets.**

## Validation

- [ ] Cluster created via Terraform
- [ ] Can destroy and recreate reliably
- [ ] Terraform state managed properly
- [ ] All IaC in version control (GitHub)

## What You Achieved

✅ Repeatable infrastructure
✅ Version-controlled configuration
✅ Foundation for GitOps
✅ Understanding of IaC principles

---

# Phase 3: Immutable Infrastructure with Packer

**Goal**: Build minimal, hardened OS images for fast, secure deployments

**Duration**: 2-3 weeks

**Why This Phase**: Manual K3s installation is slow. Pre-built images are faster, more secure, and professional.

## What You'll Learn
- Image building with Packer
- OS hardening (CIS benchmarks)
- Minimal system configuration
- Security best practices
- Update strategies

## Context: Why Minimal Images?

**Security**: Fewer packages = smaller attack surface
**Performance**: Faster boot, less resource usage
**Understanding**: Learn what's actually needed
**Professional**: Industry standard practice

## Prerequisites
- Phase 2 completed (Terraform working)
- Packer installed
- Proxmox template storage available

## Steps

### 3.1: Create Packer Template

**Build**: Ubuntu minimal + K3s binary (not configured)

```hcl
# packer/k3s-node.pkr.hcl
source "proxmox" "ubuntu-k3s" {
  # Proxmox connection
  # Ubuntu minimal ISO
  # Automated installation
}

build {
  provisioners {
    # Install K3s binary
    # Security hardening
    # Remove unnecessary packages
    # Configure systemd
  }
}
```

**What's included**:
- K3s binary (pre-downloaded)
- Container runtime
- Minimal packages (curl, vim)
- Security hardening
- NO cluster configuration (done at boot)

**What's NOT included**:
- Cluster token (injected at boot)
- Server/agent role (determined at boot)
- Network config (cloud-init handles)

### 3.2: Security Hardening Script

```bash
# packer/scripts/harden.sh
# Based on CIS Benchmark

# Disable unnecessary services
systemctl disable snapd
systemctl disable bluetooth

# Kernel hardening
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.bridge.bridge-nf-call-iptables=1

# Disable swap (K8s requirement)
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# Remove unnecessary packages
apt purge -y snapd cloud-init

# Set file permissions
chmod 600 /etc/ssh/sshd_config
```

**Why each step**: Document WHY each hardening measure.

### 3.3: Build First Image

```bash
cd packer
packer build k3s-node.pkr.hcl
```

**Result**: Proxmox template ready to clone

### 3.4: Update Terraform to Use Packer Image

```hcl
# main.tf
resource "proxmox_vm_qemu" "k3s_server" {
  clone = "k3s-node-template"  # Your Packer-built template

  # Cloud-init just configures role
  cicustom = "user=local:snippets/k3s-server-config.yml"
}
```

**Cloud-init now minimal**:
```yaml
#cloud-config
runcmd:
  - K3S_TOKEN=${token} /opt/start-k3s.sh server
```

### 3.5: Test Deployment Speed

```bash
time tofu apply
```

**Before Packer**: ~10 minutes
**After Packer**: ~3 minutes

**Why faster?** K3s already installed, just configuring.

### 3.6: Update Strategy

**Weekly image rebuilds**:
```bash
# Automated via cron or CI/CD later
packer build k3s-node.pkr.hcl
# New template created
# Terraform recreates nodes with new image
```

**This is immutable infrastructure**: Replace, don't patch.

## Validation

- [ ] Packer builds successfully
- [ ] Image includes K3s binary
- [ ] Image is hardened (run Lynis scan)
- [ ] Terraform uses Packer template
- [ ] Deployment faster than before
- [ ] Documented hardening steps

## What You Achieved

✅ Fast deployments (3 min vs 10 min)
✅ Security hardening baseline
✅ Understanding of minimal systems
✅ Update strategy defined
✅ Professional image building

---

# Phase 4: Self-Hosted Platform Services

**Goal**: Host git, container registry, and CI/CD in your cluster

**Duration**: 2-3 weeks

**Why This Phase**: Can't do full GitOps while depending on external services. Self-hosting gives control and teaches platform engineering.

## What You'll Learn
- Platform engineering concepts
- Service deployment patterns
- Persistent storage in K8s
- Backup strategies
- Bootstrap challenges

## Architecture

```
Management Cluster (K3s)
├── Gitea (self-hosted git)
├── Harbor (container registry)
├── Drone/Tekton (CI/CD)
└── Persistent storage (local-path)
```

## Prerequisites
- Phase 3 completed
- Understanding of Kubernetes storage
- Backup strategy planned

## The Bootstrap Problem

**You need**:
- Git repo to store configs
- Registry for images
- Cluster to run them

**Solution**: Multi-stage bootstrap
1. Deploy to cluster from GitHub
2. Migrate to self-hosted
3. Keep GitHub as backup

## Steps

### 4.1: Deploy Gitea (Self-Hosted Git)

```bash
# Using Helm for simplicity
helm repo add gitea-charts https://dl.gitea.io/charts/
helm install gitea gitea-charts/gitea \
  --set persistence.enabled=true \
  --set service.type=ClusterIP
```

**Why Helm?** Faster for platform services, learn it now.

**Storage**: Local path provisioner (K3s default)

### 4.2: Configure Gitea

- Create admin account
- Enable SSH (for git operations)
- Create organization: "infrastructure"
- Create repos: "terraform", "kubernetes", "packer"

### 4.3: Mirror GitHub to Gitea

```bash
# Push existing infrastructure code to Gitea
git remote add gitea http://gitea.yourdomain.local/infrastructure/terraform
git push gitea main
```

**Keep GitHub as backup** (for now)

### 4.4: Deploy Harbor (Container Registry)

```bash
helm repo add harbor https://helm.goharbor.io
helm install harbor harbor/harbor \
  --set expose.type=clusterIP \
  --set persistence.enabled=true \
  --set externalURL=https://harbor.yourdomain.local
```

**Why Harbor?** Security scanning built-in, professional grade.

### 4.5: Configure Harbor

- Create "homelab" project
- Enable vulnerability scanning
- Configure retention policies
- Create robot account for CI/CD

### 4.6: Deploy CI/CD (Drone or Tekton)

**Drone** (simpler, good for learning):
```bash
helm install drone drone/drone
```

**Or Tekton** (more K8s-native):
```bash
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
```

**Configure**:
- Connect to Gitea
- Add webhook for builds
- Configure to push to Harbor

### 4.7: First Self-Hosted Pipeline

**Goal**: Push to Gitea → Drone builds → Image to Harbor

```yaml
# .drone.yml in your app repo
kind: pipeline
name: build

steps:
  - name: build
    image: plugins/docker
    settings:
      registry: harbor.yourdomain.local
      repo: harbor.yourdomain.local/homelab/myapp
      username:
        from_secret: harbor_user
      password:
        from_secret: harbor_pass
```

**Test**:
```bash
git push gitea main
# Watch build in Drone
# Verify image in Harbor
```

### 4.8: Backup Strategy

**Critical**: These services store everything

```bash
# Velero for K8s backups
helm install velero vmware-tanzu/velero

# Configure external storage (S3, Backblaze, etc.)
# Schedule daily backups
velero schedule create daily --schedule="@daily"
```

**Also backup**:
- Database dumps (Gitea, Harbor)
- Persistent volumes
- Encryption keys

## Validation

- [ ] Gitea accessible and working
- [ ] Harbor accessible and scanning images
- [ ] CI/CD pipeline working
- [ ] Code in self-hosted git
- [ ] Images in self-hosted registry
- [ ] Backups configured and tested
- [ ] GitHub still mirrored (safety net)

## What You Achieved

✅ Self-hosted development platform
✅ Full CI/CD pipeline
✅ Image scanning capability
✅ Understanding of platform services
✅ Backup and recovery strategy

## Troubleshooting

**Persistent storage issues**: Check PVC status
**Gitea SSH not working**: Check service ports
**Harbor scanner failing**: Check internet access for CVE database

---

# Phase 5: GitOps with ArgoCD

**Goal**: Everything deployed declaratively from git

**Duration**: 2 weeks

**Why This Phase**: GitOps is the modern deployment pattern. Git becomes single source of truth.

## What You'll Learn
- GitOps principles
- ArgoCD architecture
- App-of-apps pattern
- Sync strategies
- Declarative everything

## Concept: GitOps

**Traditional**: kubectl apply manually
**GitOps**: Git commit → automatic deployment

**Benefits**:
- Audit trail (git history)
- Rollback (git revert)
- Disaster recovery (redeploy from git)
- Collaboration (pull requests)

## Prerequisites
- Phase 4 completed
- All manifests in git
- Understanding of K8s resources

## Steps

### 5.1: Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

**Get password**:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 5.2: Connect ArgoCD to Gitea

```bash
argocd repo add http://gitea.yourdomain.local/infrastructure/kubernetes \
  --username admin \
  --password <password>
```

### 5.3: Create Application Structure in Git

```
gitea.com/infrastructure/kubernetes/
├── argocd/
│   └── apps/
│       ├── platform-services.yaml
│       ├── monitoring.yaml
│       └── applications.yaml
├── platform/
│   ├── gitea/
│   ├── harbor/
│   └── drone/
├── monitoring/
│   ├── prometheus/
│   └── grafana/
└── apps/
    └── mywebsite/
```

### 5.4: Create App-of-Apps Pattern

```yaml
# argocd/apps/platform-services.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: platform-services
spec:
  project: default
  source:
    repoURL: http://gitea.yourdomain.local/infrastructure/kubernetes
    path: platform
    targetRevision: main
  destination:
    server: https://kubernetes.default.svc
    namespace: platform
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

**What's happening**: ArgoCD watches git, auto-deploys changes.

### 5.5: Deploy Your Website via GitOps

```yaml
# apps/mywebsite/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mywebsite
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: web
        image: harbor.yourdomain.local/homelab/mywebsite:v1.0.0
```

**Deployment**:
```bash
git add apps/mywebsite/
git commit -m "Deploy website v1.0.0"
git push gitea main

# ArgoCD automatically deploys
```

**Update**:
```bash
# Change image tag to v1.0.1
git commit -m "Update website to v1.0.1"
git push

# ArgoCD auto-updates
```

### 5.6: Set Up Sync Policies

**Auto-sync**: Changes deploy automatically
**Manual sync**: Require approval
**Prune**: Delete resources removed from git
**Self-heal**: Fix manual changes

**For production apps**: Manual sync
**For platform**: Auto-sync with self-heal

### 5.7: Integrate with CI/CD

**Pipeline updates git**:
```yaml
# .drone.yml
steps:
  - name: build
    # Build and push image to Harbor

  - name: update-manifest
    image: alpine/git
    commands:
      - git clone http://gitea.local/infrastructure/kubernetes
      - cd kubernetes/apps/mywebsite
      - sed -i 's/image:.*/image: harbor.local\/homelab\/mywebsite:${DRONE_TAG}/' deployment.yaml
      - git commit -m "Update to ${DRONE_TAG}"
      - git push
```

**Flow**: Code push → Build → Image → Update manifest → ArgoCD deploys

## Validation

- [ ] ArgoCD installed and accessible
- [ ] Connected to Gitea
- [ ] App-of-apps pattern working
- [ ] Platform services managed by ArgoCD
- [ ] Applications deployed via git commits
- [ ] Pipeline updates manifests automatically
- [ ] Rollback works (git revert)

## What You Achieved

✅ Full GitOps workflow
✅ Declarative everything
✅ Git as source of truth
✅ Automated deployments
✅ Professional deployment pattern

---

# Phase 6: Security Hardening & Scanning

**Goal**: Production-grade security scanning and enforcement

**Duration**: 2-3 weeks

**Why This Phase**: Now that platform works, make it secure. This is DevSecOps.

## What You'll Learn
- Container scanning
- Image signing
- Policy enforcement
- Runtime security
- Network policies
- Secrets management

## Security Layers

```
Code → Image → Registry → Cluster → Runtime
 ↓      ↓        ↓          ↓         ↓
Scan   Scan    Scan      Policy   Monitor
```

## Prerequisites
- Phase 5 completed
- Applications running
- Harbor configured

## Steps

### 6.1: Enable Harbor Vulnerability Scanning

**Already built-in to Harbor**

```bash
# In Harbor UI:
# Projects → Configuration → Enable vulnerability scanning
# Automatically scan on push: Yes
# Prevent vulnerable images: Yes (severity: High)
```

**Test**:
```bash
docker push harbor.local/homelab/myapp:latest
# Harbor scans automatically
# View vulnerabilities in UI
```

### 6.2: Add Trivy to CI/CD Pipeline

```yaml
# .drone.yml
steps:
  - name: security-scan
    image: aquasec/trivy
    commands:
      - trivy image --severity HIGH,CRITICAL myapp:latest
      - trivy fs --security-checks vuln,config .
```

**Fails build if**: Critical vulnerabilities found

### 6.3: Implement Image Signing with Cosign

```bash
# Install Cosign
# Generate keys
cosign generate-key-pair

# Sign images in pipeline
cosign sign --key cosign.key harbor.local/homelab/myapp:v1.0.0
```

**Verification**: Only signed images deploy

### 6.4: Deploy Policy Enforcement (OPA Gatekeeper)

```bash
helm install gatekeeper gatekeeper/gatekeeper

# Create policies
kubectl apply -f policies/
```

**Example policy**: Only images from Harbor registry
```yaml
# policies/allowed-registries.yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sAllowedRepos
metadata:
  name: allowed-repositories
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
  parameters:
    repos:
      - "harbor.yourdomain.local"
```

**Test**: Try deploying from Docker Hub → Rejected

### 6.5: Network Policies

**Isolate workloads**:
```yaml
# network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
# Then allow specific traffic
```

**Why?** Defense in depth, limit blast radius

### 6.6: Secrets Management with Sealed Secrets

**Problem**: Can't commit secrets to git

**Solution**: Sealed Secrets (or Vault)

```bash
# Install Sealed Secrets controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.18.0/controller.yaml

# Seal a secret
echo -n mypassword | kubectl create secret generic mysecret --dry-run=client --from-file=password=/dev/stdin -o yaml | \
  kubeseal -o yaml > mysealedsecret.yaml

# Commit sealed secret to git (safe)
git add mysealedsecret.yaml
```

**Controller decrypts** in cluster

### 6.7: Runtime Security with Falco

```bash
helm install falco falcosecurity/falco

# Monitor suspicious activity
kubectl logs -n falco -l app=falco
```

**Alerts on**:
- Shell spawned in container
- Unexpected network connections
- File modifications
- Privilege escalations

### 6.8: Security Scanning Dashboard

**Aggregate security data**:
- Harbor vulnerability counts
- Gatekeeper policy violations
- Falco alerts
- Network policy denials

**Visualize in Grafana**

## Validation

- [ ] All images scanned before deployment
- [ ] Vulnerable images blocked
- [ ] Images signed and verified
- [ ] Policies enforced (Gatekeeper)
- [ ] Network policies active
- [ ] Secrets encrypted in git
- [ ] Runtime monitoring active
- [ ] Security dashboard created

## What You Achieved

✅ Multi-layer security
✅ Automated scanning
✅ Policy enforcement
✅ Secrets management
✅ Runtime protection
✅ Professional security posture

---

# Phase 7: Observability & Monitoring

**Goal**: Full visibility into cluster and applications

**Duration**: 2 weeks

**Why This Phase**: Can't secure what you can't see. Monitoring is critical.

## What You'll Learn
- Prometheus metrics
- Grafana dashboards
- Log aggregation (Loki)
- Distributed tracing
- Alerting

## The Stack

```
Metrics: Prometheus
Visualization: Grafana
Logs: Loki
Traces: Tempo (optional)
Alerts: Alertmanager
```

## Prerequisites
- Phase 6 completed
- Understanding of metrics
- Storage for logs/metrics

## Steps

### 7.1: Deploy Prometheus Stack

```bash
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --set prometheus.prometheusSpec.retention=30d \
  --set grafana.adminPassword=admin
```

**Includes**:
- Prometheus (metrics)
- Grafana (visualization)
- Alertmanager (alerts)
- Node exporters (host metrics)
- K8s metrics

### 7.2: Access Grafana

```bash
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80
# Open http://localhost:3000
# Login: admin/admin
```

**Pre-built dashboards available**:
- Kubernetes cluster overview
- Node metrics
- Pod metrics
- Persistent volumes

### 7.3: Deploy Loki (Log Aggregation)

```bash
helm install loki grafana/loki-stack \
  --set promtail.enabled=true \
  --set grafana.enabled=false
```

**Promtail** collects logs from all pods

### 7.4: Configure Grafana Data Sources

**Add Loki to Grafana**:
- Configuration → Data Sources → Add Loki
- URL: http://loki:3100

**Now you have**:
- Metrics (Prometheus)
- Logs (Loki)
- Correlated in Grafana

### 7.5: Create Custom Dashboards

**For your website**:
- Request rate
- Error rate
- Response time
- Active connections

**For platform**:
- Gitea activity
- Harbor image counts
- Pipeline success rate
- ArgoCD sync status

### 7.6: Set Up Alerts

```yaml
# alerts/website-down.yaml
apiVersion: v1
kind: PrometheusRule
metadata:
  name: website-alerts
spec:
  groups:
  - name: website
    rules:
    - alert: WebsiteDown
      expr: up{job="mywebsite"} == 0
      for: 5m
      annotations:
        summary: "Website is down"
```

**Alert channels**:
- Email
- Slack
- Discord
- PagerDuty (professional)

### 7.7: Application Instrumentation

**Add metrics to your app**:
```go
// Example in Go
import "github.com/prometheus/client_golang/prometheus/promhttp"

http.Handle("/metrics", promhttp.Handler())
```

**Prometheus scrapes** /metrics endpoint

### 7.8: Log Aggregation Best Practices

**Structured logging**:
```json
{
  "timestamp": "2024-01-01T12:00:00Z",
  "level": "error",
  "message": "Database connection failed",
  "user_id": "123",
  "trace_id": "abc-def"
}
```

**Easier to query** in Loki/Grafana

## Validation

- [ ] Prometheus collecting metrics
- [ ] Grafana dashboards showing data
- [ ] Loki aggregating logs
- [ ] Custom dashboards created
- [ ] Alerts configured and tested
- [ ] Application metrics exposed
- [ ] Can correlate logs and metrics

## What You Achieved

✅ Full observability stack
✅ Metrics and logs centralized
✅ Custom dashboards
✅ Alerting configured
✅ Professional monitoring

---

# Phase 8: Advanced Networking & Firewalls

**Goal**: Production-grade networking with VLANs, firewalls, and segmentation

**Duration**: 2-3 weeks

**Why This Phase**: Security through network isolation. Professional networks are segmented.

## What You'll Learn
- Network segmentation
- VLANs
- Firewall rules (pfSense/OPNsense)
- Service mesh (optional)
- Ingress controllers
- Certificate management

## Architecture

```
Internet
  ↓
Cloudflare Tunnel (encrypted)
  ↓
Firewall (pfSense/OPNsense)
  ├─ VLAN 10: Management (Proxmox)
  ├─ VLAN 20: K8s Nodes
  ├─ VLAN 30: Platform Services
  └─ VLAN 40: Applications

Each VLAN has firewall rules
```

## Prerequisites
- Phase 7 completed
- Understanding of networking
- Firewall appliance (or VM)

## Steps

### 8.1: Deploy Firewall (pfSense or OPNsense)

**VM in Proxmox**:
- 2 NICs (WAN and LAN)
- 2 CPU, 2GB RAM
- pfSense ISO

**Configure VLANs**:
- VLAN 10: 192.168.10.0/24 (Management)
- VLAN 20: 192.168.20.0/24 (K8s)
- VLAN 30: 192.168.30.0/24 (Platform)
- VLAN 40: 192.168.40.0/24 (Apps)

### 8.2: Firewall Rules

**Default deny, explicit allow**:

```
VLAN 20 (K8s) can access:
- VLAN 30 (Platform) on specific ports
- Internet (for updates)

VLAN 30 (Platform) can access:
- Internet (for CVE database)

VLAN 40 (Apps) can access:
- VLAN 30 (database) on port 5432 only
- Internet via proxy

Management (VLAN 10):
- Access all (for administration)
- Source IP restricted
```

### 8.3: Deploy Ingress Controller

**Nginx Ingress**:
```bash
helm install ingress-nginx ingress-nginx/ingress-nginx
```

**Why?** Single entry point, TLS termination, path-based routing

### 8.4: Certificate Management (cert-manager)

```bash
helm install cert-manager jetstack/cert-manager --set installCRDs=true

# Configure Let's Encrypt
kubectl apply -f letsencrypt-issuer.yaml
```

**Automatic TLS certificates** for all services

### 8.5: Configure Ingress for Services

```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mywebsite
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - mywebsite.yourdomain.com
    secretName: mywebsite-tls
  rules:
  - host: mywebsite.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: mywebsite
            port:
              number: 80
```

**Automatic HTTPS** via cert-manager

### 8.6: Service Mesh (Optional - Advanced)

**Linkerd** (simpler) or **Istio** (full-featured)

```bash
# Linkerd
linkerd install | kubectl apply -f -
linkerd check
```

**Benefits**:
- mTLS between services
- Traffic metrics
- Circuit breaking
- Retries and timeouts

**Complexity**: High, do later if needed

### 8.7: WAF (Web Application Firewall)

**ModSecurity with Nginx**:
```yaml
# Protect against OWASP Top 10
nginx.ingress.kubernetes.io/enable-modsecurity: "true"
nginx.ingress.kubernetes.io/enable-owasp-core-rules: "true"
```

### 8.8: DDoS Protection

**Cloudflare** provides:
- DDoS mitigation
- WAF
- Rate limiting
- Bot protection

**Enable Cloudflare proxy** on DNS records

## Validation

- [ ] VLANs configured and isolated
- [ ] Firewall rules tested
- [ ] Ingress controller routing traffic
- [ ] TLS certificates automatic
- [ ] Services accessible via domains
- [ ] Network policies enforced
- [ ] WAF blocking attacks

## What You Achieved

✅ Segmented network
✅ Firewall protection
✅ Automatic TLS
✅ Professional ingress
✅ DDoS protection

---

# Phase 9: PXE Boot & Physical Nodes

**Goal**: Add physical devices to cluster using network boot

**Duration**: 2 weeks

**Why This Phase**: Unified management of VMs and physical hardware.

## What You'll Learn
- PXE boot server setup
- Network boot process
- DHCP/TFTP configuration
- Physical node management
- Hybrid cluster management

## Prerequisites
- Phase 8 completed
- Physical devices available
- Understanding of network boot

## Steps

### 9.1: Deploy PXE Server (LXC)

**Proxmox LXC container**:
```bash
# dnsmasq for DHCP/TFTP
# nginx for HTTP boot files
# Your Packer-built images
```

### 9.2: Configure DHCP

```bash
# dnsmasq.conf
dhcp-range=192.168.20.100,192.168.20.200,12h
dhcp-boot=pxelinux.0
enable-tftp
tftp-root=/var/lib/tftpboot
```

### 9.3: Setup Boot Menu

```
PXE Menu:
1. K3s Server (auto-install)
2. K3s Agent (auto-install)
3. Rescue/Debug mode
```

### 9.4: Physical Device Boot

**Steps**:
1. Configure BIOS for network boot
2. Boot device
3. PXE menu appears
4. Select "K3s Agent"
5. Auto-install from Packer image
6. Cloud-init configures
7. Joins cluster

**No manual steps** after initial BIOS config

### 9.5: Wake-on-LAN Integration

```bash
# Wake machines remotely
wakeonlan AA:BB:CC:DD:EE:FF
```

**Automation**: Wake before updates, sleep when idle

### 9.6: Unified Management

**Terraform manages both**:
```hcl
# VMs on Proxmox
resource "proxmox_vm_qemu" "k3s_vm" { }

# Physical nodes via provisioner
resource "null_resource" "physical_node" {
  provisioner "remote-exec" {
    # Trigger PXE reboot
  }
}
```

## Validation

- [ ] PXE server operational
- [ ] Physical device boots from network
- [ ] Auto-joins cluster
- [ ] VMs and physical in same cluster
- [ ] Wake-on-LAN working
- [ ] Unified updates

## What You Achieved

✅ PXE boot infrastructure
✅ Physical nodes as cattle
✅ Hybrid VM/physical cluster
✅ Automated physical provisioning

---

# Phase 10: Cluster API & Multi-Cluster

**Goal**: Declarative cluster management and multi-cluster orchestration

**Duration**: 3-4 weeks

**Why This Phase**: Manage clusters like applications. Scale to multiple environments.

## What You'll Learn
- Cluster API concepts
- Multi-cluster management
- Cluster lifecycle
- Federation (optional)

## Prerequisites
- Phase 9 completed
- Understanding of K8s operators
- Stable management cluster

## Steps

### 10.1: Install Cluster API

```bash
# On management cluster
clusterctl init --infrastructure proxmox
```

### 10.2: Define Cluster as Code

```yaml
# clusters/production.yaml
apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
metadata:
  name: production
spec:
  controlPlaneRef:
    kind: KubeadmControlPlane
    name: production-control-plane
  infrastructureRef:
    kind: ProxmoxCluster
    name: production
---
# Control plane and worker definitions
```

### 10.3: Deploy Cluster Declaratively

```bash
kubectl apply -f clusters/production.yaml

# Cluster API creates VMs on Proxmox
# Installs K8s
# Returns kubeconfig
```

### 10.4: Multi-Cluster Architecture

```
Management Cluster
  ├── Manages: Production Cluster
  ├── Manages: Staging Cluster
  └── Manages: Dev Cluster

ArgoCD ApplicationSets
  ├── Deploys to Production
  ├── Deploys to Staging
  └── Deploys to Dev
```

### 10.5: GitOps Multi-Cluster

```yaml
# applicationset.yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: myapp
spec:
  generators:
  - list:
      elements:
      - cluster: production
        url: https://prod-cluster
      - cluster: staging
        url: https://staging-cluster
  template:
    spec:
      source:
        path: apps/myapp/{{cluster}}
```

**One git commit** → deploys to all clusters

## Validation

- [ ] Cluster API operational
- [ ] Can create clusters declaratively
- [ ] Multiple clusters managed
- [ ] ArgoCD deploys to all
- [ ] GitOps multi-cluster working

## What You Achieved

✅ Cluster API mastery
✅ Multi-cluster management
✅ Clusters as cattle
✅ Production/staging/dev environments

---

# Phase 11: Production Hardening

**Goal**: Make everything production-ready

**Duration**: 2-3 weeks

**Why This Phase**: Polish, performance, and reliability.

## Checklist

### High Availability
- [ ] 3+ control plane nodes
- [ ] Multiple replicas for all services
- [ ] Database replication
- [ ] Load balancing

### Backup & Disaster Recovery
- [ ] Automated daily backups (Velero)
- [ ] Off-site backup storage
- [ ] Tested restore procedures
- [ ] Backup monitoring/alerts
- [ ] Documented DR runbook

### Performance Tuning
- [ ] Resource limits set
- [ ] HPA (Horizontal Pod Autoscaler)
- [ ] VPA (Vertical Pod Autoscaler)
- [ ] Network optimization
- [ ] Storage performance tested

### Security Audit
- [ ] CIS Benchmark compliance
- [ ] Penetration testing
- [ ] Vulnerability scan clean
- [ ] Secrets rotated regularly
- [ ] Audit logging enabled
- [ ] Incident response plan

### Documentation
- [ ] Architecture diagrams
- [ ] Runbooks for common tasks
- [ ] Troubleshooting guides
- [ ] Onboarding documentation
- [ ] API documentation

### Compliance
- [ ] GDPR considerations (if applicable)
- [ ] Data retention policies
- [ ] Access control documented
- [ ] Change management process

## What You Achieved

✅ Production-ready platform
✅ HA and resilience
✅ Comprehensive backups
✅ Security hardened
✅ Fully documented

---

# Phase 12: Showcase & Portfolio

**Goal**: Public demonstration of your work

**Duration**: 1-2 weeks

**Why This Phase**: Show the world what you built.

## Steps

### 12.1: Public Website

**Showcase**:
- Architecture diagrams
- Technology stack
- Security measures
- Monitoring dashboards (read-only)
- Blog about your journey

### 12.2: GitHub Repository

**Public repo with**:
- All infrastructure code
- Documentation
- Diagrams
- Blog posts
- Lessons learned

**Sanitize**: Remove secrets, internal IPs

### 12.3: Portfolio Site

**Sections**:
- About the project
- Technologies used
- Challenges overcome
- Architecture
- Security approach
- Monitoring/observability
- Links to code

### 12.4: Blog Series

**Topics**:
1. "Building a Production K8s Platform from Scratch"
2. "Security Hardening: A DevSecOps Journey"
3. "GitOps in Practice: Lessons Learned"
4. "Immutable Infrastructure with Packer"
5. "Multi-Cluster Management with Cluster API"

### 12.5: Public Monitoring Dashboard

**Read-only Grafana**:
- Cluster health
- Application metrics
- Security scan results
- Build pipeline stats

**No sensitive data**

## What You Achieved

✅ Public portfolio
✅ Demonstrated expertise
✅ Shareable case study
✅ Professional presentation

---

# Maintenance & Continuous Improvement

## Weekly Tasks
- Review security scan results
- Update images (Packer rebuilds)
- Review monitoring alerts
- Backup verification

## Monthly Tasks
- Security audit
- Performance review
- Cost optimization (if cloud)
- Documentation updates
- Dependency updates

## Quarterly Tasks
- Disaster recovery drill
- Architecture review
- Technology evaluation
- Training on new tools

---

# Learning Resources

## Books
- "Kubernetes: Up and Running" (O'Reilly)
- "The DevOps Handbook" (IT Revolution)
- "Site Reliability Engineering" (Google)

## Online
- Kubernetes documentation
- CNCF landscape
- DevSecOps toolkit
- CIS Benchmarks

## Communities
- r/kubernetes
- r/selfhosted
- CNCF Slack
- Local DevOps meetups

---

# Success Metrics

## Technical
- [ ] 99.9% uptime for production apps
- [ ] < 5 minute deployment time
- [ ] Zero high/critical vulnerabilities
- [ ] < 1 hour recovery time (DR)
- [ ] 100% GitOps (no manual deploys)

## Learning
- [ ] Can explain every component
- [ ] Can rebuild from scratch in 1 day
- [ ] Have presented/blogged about project
- [ ] Comfortable with all tools
- [ ] Ready for professional DevOps role

---

# Final Thoughts

**This roadmap is ambitious but achievable.**

**Keys to success**:
1. **Go in order** - Each phase builds on previous
2. **Don't skip phases** - Especially early ones
3. **Document everything** - Future you will thank you
4. **Break things** - Learning happens during recovery
5. **Share your journey** - Teaching solidifies learning
6. **Be patient** - This is months of work
7. **Have fun** - This is a playground

**Timeline**:
- Realistic: 6-9 months (part-time)
- Aggressive: 3-4 months (full-time)
- Comfortable: 12 months (learning pace)

**You'll emerge with**:
- Deep K8s knowledge
- DevSecOps expertise
- Portfolio project
- Production-ready skills
- Professional confidence

**Now get building! 🚀**

---

# Appendix: Quick Reference

## Common Commands

```bash
# Cluster management
kubectl get nodes
kubectl get pods -A
kubectl describe pod <name>

# Terraform
tofu init
tofu plan
tofu apply
tofu destroy

# Packer
packer build template.pkr.hcl

# ArgoCD
argocd app list
argocd app sync <app>

# Monitoring
kubectl logs -f <pod>
kubectl port-forward svc/grafana 3000:80
```

## Critical Files

```
/infrastructure/       - Terraform code
/packer/              - Image templates
/kubernetes/          - K8s manifests
/docs/                - Documentation
/.github/workflows/   - CI/CD pipelines
```

## Emergency Procedures

**Cluster Down**:
1. Check node status: `kubectl get nodes`
2. Check system logs: `journalctl -u k3s`
3. Restart K3s: `systemctl restart k3s`

**Restore from Backup**:
1. Access Velero: `velero restore create --from-backup <name>`
2. Verify: `kubectl get all`

**Security Incident**:
1. Isolate affected nodes
2. Check Falco alerts
3. Review audit logs
4. Restore from known-good backup
5. Post-mortem documentation

---

**Last Updated**: 2024
**Version**: 1.0
**Status**: Living Document (update as you progress)
