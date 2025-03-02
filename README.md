# Home Lab

Welcome to my home lab project. The goal of this project is to create an environment for learning with minimal setup.
To start with, the setup will be intentionally simple. My hope is to reach a point where I feel the need for a better
solution and grow into more advanced tools and services. But sooner than later this will be properly over-engineered anyway.

## Table of Contents
- [Project Structure](#project-structure)
- [Setup](#setup)
- [Observability](#observability)

## MVP iteration 1
- Setup the simplest possible environment.
- No need for persistance. This is run on demand.
- Run a simple application.

## MVP iteration 2
- Setup logging and monitoring for containers.


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

## Observability

The observability stack used is Prometheus, Loki, Allow and Grafana.

**Make sure the Docker daemon is running**

Run the following command to start the observability stack:
```bash
docker compose -f ./observability/docker-compose.yaml up -d
```

Log in to grafana on port 3000 with password `admin` and user `admin`. If other docker continers are running, this stack will include those as well.
