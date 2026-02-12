

## Overview
This repository uses bootc to create a bootable container image.

Currently using a headless Fedora server-based image with the following in mind:
- **K3s** - Lightweight Kubernetes distribution for container orchestration
- **GitOps** - Infrastructure-as-code workflow with Flux or ArgoCD
- **Hardware Acceleration** - Intel VA-API support for media transcoding (Jellyfin)
- **Remote Management** - Cockpit web console and Tailscale VPN
- **Dev Containers** - Podman-based development environments

## What's Included

### Core Components
- **Fedora bootc** (server base) - Headless, optimized for container workloads
- **Podman** - Rootless container runtime for dev containers
- **K3s** - Kubernetes with Traefik ingress, CoreDNS, and local storage
- **Tailscale** - Secure remote access VPN

### Kubernetes & GitOps
- **kubectl** - Kubernetes CLI
- **helm** - Kubernetes package manager
- **git** - Version control for GitOps workflows

### Management & Monitoring
- **Cockpit** - Web UI at `https://<server-ip>:9090`
  - Container management (Podman integration)
  - Disk and network configuration
  - System monitoring and logs
- **htop, iotop** - Resource monitoring
- **smartmontools** - Disk health monitoring

### Hardware Acceleration
- **libva** + **libva-intel-media-driver** - Intel Quick Sync for video transcoding

## Usage

### Development Workflow

**Application Development**
- Use dev containers via Podman:
  ```bash
  podman run -it --rm -v $(pwd):/workspace python:3.11 bash
  ```
- Or use VSCode/Cursor with Dev Containers Extension (Will add a .devcontainer configuration in the future)

## Building

The image is automatically built via GitHub Actions and pushed to GitHub Container Registry:
```
ghcr.io/<your-username>/bootc:latest
```

**Manual build:**
```bash
podman build -t bootc .
```

## Deployment

Use `bootc-image-builder` or install directly to disk:
```bash
bootc install to-filesystem --karg=console=ttyS0 /dev/sda
```             