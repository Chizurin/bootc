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
        container-selinux \
        # Networking and remote access
        tailscale \
        firewalld \
        # Kubernetes and GitOps tools
        git \
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

# Install k3s SELinux policy first (must precede install script)
RUN dnf install -y https://rpm.rancher.io/k3s/stable/common/centos/8/noarch/k3s-selinux-1.6-1.el8.noarch.rpm && \
    dnf clean all

# Install k3s — pipe into sh, skip start (no kernel during build)
RUN curl -sfL https://get.k3s.io | \
    INSTALL_K3S_SKIP_START=true \
    INSTALL_K3S_EXEC="server --write-kubeconfig-mode=644" \
    sh -

# Enable k3s and supporting services on boot
RUN systemctl enable k3s \
    tailscaled \
    firewalld

RUN bootc container lint