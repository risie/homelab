# Home Lab

Welcome to my home lab project. The goal of this project is to create an environment for learning with minimal setup.
To start with, the setup will be intentionally simple. My hope is to reach a point where I feel the need for a better
solution and grow into more advanced tools and services. But sooner than later this will be properly over-engineered anyway.

## Table of Contents
- [Project Structure](#project-structure)
- [Setup](#setup)
- [K3s Cluster Infrastructure](#k3s-cluster-infrastructure)
- [Observability](#observability)

## MVP iteration 1
- Setup the simplest possible environment.
- No need for persistance. This is run on demand.
- Run a simple application.

## MVP iteration 2
- Setup logging and monitoring for containers.

## MVP iteration 3
- Setup K3s cluster on Proxmox with OpenTofu
- Deploy applications to Kubernetes cluster


## Project Structure

The project directory is structured as follows:
```markdown
Homelab/
├── .gitignore
├── README.md
├── dummy-app/
│   ├── Dockerfile
│   ├── go.mod
│   └── main.go
├── infrastructure/
│   ├── README.md
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   ├── quick-start.sh
│   ├── upload-snippets.sh
│   └── cloud-init/
│       ├── k3s-server-user.yml
│       └── k3s-agent-user.yml
├── observability/
│   ├── alloy/
│   │   └── config.alloy
│   ├── docker-compose.yaml
│   └── grafana/
│       └── provisioning/
│           └── datasources/
│               └── datasource.yaml
```

## Setup

The first iteration of the home lab will be running locally and will not use any additional hardware.
I will however use virtualization of some form to start with.
- *No setup required.*

## Building and Running an app inside a Container

This is the first test where I just deploy a simple Go application inside a Docker container.

### Steps to Build and Run the Docker Image

1. **Build the Docker image**:
    ```sh
    docker build -t dummy-app -f ./dummy-app/Dockerfile ./dummy-app
    ```

2. **Run the Docker container**:
    ```sh
    docker run -p 8080:8080 dummy-app
    ```

## K3s Cluster Infrastructure

A production-ready K3s cluster setup on Proxmox using OpenTofu. This solves the common "cloud-init too large" error by using minimal cloud-init configurations stored as Proxmox snippets.

### Features

- **4-node K3s cluster** (1 server + 3 agents)
- **Smart cloud-init approach** - avoids the 4KB size limit
- **Automated deployment** with OpenTofu/Terraform
- **Static IP configuration** for all nodes
- **Secure token generation** for cluster authentication

### Quick Start

```bash
cd infrastructure

# Interactive setup wizard
./quick-start.sh

# Or manual setup
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Upload cloud-init snippets to Proxmox
./upload-snippets.sh -h <proxmox-host-ip>

# Deploy the cluster
tofu init
tofu apply
```

### What Makes This Smart?

1. **Solves the "too large" problem** - Minimal cloud-init (under 4KB) stored as Proxmox snippets
2. **Proper orchestration** - Server installs first, then agents join automatically
3. **No manual steps** - Everything automated from VM creation to K3s installation
4. **Production-ready** - Swap disabled, kubeconfig accessible, traefik disabled for custom ingress

For detailed documentation, see [infrastructure/README.md](infrastructure/README.md)

## Observability

The observability stack used is Prometheus, Loki, Allow and Grafana.

**Make sure the Docker daemon is running**

Run the following command to start the observability stack:
```bash
docker compose -f ./observability/docker-compose.yaml up -d
```

Log in to grafana on port 3000 with password `admin` and user `admin`. If other docker continers are running, this stack will include those as well.
