ARG FEDORA_MAJOR_VERSION=rawhide

FROM quay.io/fedora/fedora-bootc:${FEDORA_MAJOR_VERSION}

RUN curl -s -o /etc/yum.repos.d/tailscale.repo https://pkgs.tailscale.com/stable/centos/9/tailscale.repo

RUN dnf -y update --setopt=tsflags=nodocs --security && \
    dnf -y install \
        # Core bootc and container runtime
        bootc \
        podman \
        podman-docker \
        podman-compose \
        systemd-container \
        # Networking and remote access
        tailscale \
        firewalld \
        # Kubernetes and GitOps tools
        git \
        kubectl \
        helm \
        # Web-based management (Cockpit)
        cockpit \
        cockpit-podman \
        cockpit-storaged \
        cockpit-networkmanager \
        cockpit-selinux \
        # Hardware acceleration for media transcoding
        libva \
        libva-intel-media-driver \
        libva-utils \
        # System monitoring and administration
        vim \
        make \
        htop \
        iotop \
        lm_sensors \
        smartmontools \
        bash-completion \
        tmux \
        # Storage and file transfer
        rsync \
        nfs-utils && \
    dnf clean all

# Enable container access to GPU/DRI devices for hardware transcoding
RUN setsebool -P container_use_devices on && \
    setsebool -P container_use_dri_devices on

# Enable Cockpit web console for remote management
RUN systemctl enable cockpit.socket

# Install K3s - lightweight Kubernetes for homelab
# Install in "server" mode for a control plane node
# --write-kubeconfig-mode 644 makes kubectl work without sudo
RUN curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --write-kubeconfig-mode=644" sh -

RUN bootc container lint

