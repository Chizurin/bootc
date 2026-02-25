ARG FEDORA_MAJOR_VERSION=rawhide

FROM quay.io/fedora/fedora-bootc:${FEDORA_MAJOR_VERSION}

RUN curl -s -o /etc/yum.repos.d/tailscale.repo https://pkgs.tailscale.com/stable/centos/9/tailscale.repo

RUN dnf -y update --setopt=tsflags=nodocs --security && \
    dnf -y install \
        bootc \
        podman \
        podman-docker \
        podman-compose \
        systemd-container \
        container-selinux \
        https://rpm.rancher.io/k3s/stable/common/centos/8/noarch/k3s-selinux-1.6-1.el8.noarch.rpm \
        tailscale \
        firewalld \
        git \
        helm \
        cockpit \
        cockpit-podman \
        cockpit-storaged \
        cockpit-networkmanager \
        cockpit-selinux \
        libva \
        libva-intel-media-driver \
        libva-utils \
        vim \
        make \
        htop \
        iotop \
        lm_sensors \
        smartmontools \
        bash-completion \
        tmux \
        rsync \
        nfs-utils && \
    dnf clean all

RUN setsebool -P container_use_devices on && \
    setsebool -P container_use_dri_devices on

RUN systemctl enable cockpit.socket

RUN curl -sfL https://get.k3s.io | \
    INSTALL_K3S_SKIP_START=true \
    INSTALL_K3S_EXEC="server --write-kubeconfig-mode=644" \
    sh -s -

RUN systemctl enable k3s \
    tailscaled \
    firewalld

RUN bootc container lint