# Homelab Bootc Server

This repository uses bootc to create a bootable container image for a Kubernetes-powered homelab server.

## Overview

This is a headless Fedora server image built with:
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
- Supports Jellyfin, Plex, and other media services in K8s

## Usage

### Deploying Services

**Option 1: GitOps with Flux**
```bash
flux bootstrap github --owner=<your-username> --repository=<your-repo>
```

**Option 2: Helm Charts**
```bash
helm repo add jellyfin https://jellyfin.github.io/jellyfin-helm/
helm install jellyfin jellyfin/jellyfin
```

**Option 3: kubectl Manifests**
```bash
kubectl apply -f deployment.yaml
```

### Development Workflow

**Infrastructure Development** (Helm charts, K8s manifests):
- Done directly on the server with `kubectl`, `helm`, `git`, `vim`

**Application Development** (Python, Node.js, etc.):
- Use dev containers via Podman:
  ```bash
  podman run -it --rm -v $(pwd):/workspace python:3.11 bash
  ```
- Or use VSCode/Cursor with dev containers extension

### Accessing the Server

**Cockpit Web Console:**
- `https://<server-ip>:9090`
- Manage containers, disks, network, view logs

**Tailscale Remote Access:**
```bash
tailscale up
# Access via Tailscale IP from anywhere
```

**Kubernetes API:**
```bash
kubectl get nodes
kubectl get pods -A
```

## Hardware Acceleration Setup

For Jellyfin or other media services to use hardware transcoding:

1. **In K8s manifests**, mount the GPU device:
   ```yaml
   volumeMounts:
     - name: dri
       mountPath: /dev/dri
   volumes:
     - name: dri
       hostPath:
         path: /dev/dri
   ```

2. **Verify VA-API** on the host:
   ```bash
   vainfo  # Should show Intel GPU capabilities
   ```

## Building

The image is automatically built via GitHub Actions and pushed to GitHub Container Registry:
```
ghcr.io/<your-username>/bootc:latest
```

**Manual build:**
```bash
podman build -t homelab-bootc .
```

## Deployment

Use `bootc-image-builder` or install directly to disk:
```bash
bootc install to-filesystem --karg=console=ttyS0 /dev/sda
```

## Post-Installation

1. **Start Tailscale:**
   ```bash
   systemctl start tailscaled
   tailscale up
   ```

2. **Verify K3s:**
   ```bash
   kubectl get nodes
   systemctl status k3s
   ```

3. **Access Cockpit:**
   - Navigate to `https://<server-ip>:9090`

4. **Deploy your first service:**
   ```bash
   kubectl apply -f jellyfin.yaml
   ```