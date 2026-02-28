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
        cockpit-pcp \
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

ARG K8S_VERSION=1.32.3

COPY usr/ /usr/

# Install k3s binary directly (avoids install script issues during container build)
RUN curl -Lo /usr/local/bin/k3s \
    https://github.com/k3s-io/k3s/releases/download/v${K8S_VERSION}%2Bk3s1/k3s && \
    chmod a+x /usr/local/bin/k3s

RUN systemctl enable k3s \
    tailscaled \
    firewalld

# Reminder: Add flannel for second node
# Firewall rules: k3s API server, Minecraft, Simple Voice Chat (MC), Steam Server, Cockpit UI, pod networking
RUN firewall-offline-cmd --add-port=6443/tcp && \
    firewall-offline-cmd --add-port=30565/tcp && \
    firewall-offline-cmd --add-port=30566/udp && \
    firewall-offline-cmd --add-port=27015/udp && \
    firewall-offline-cmd --add-port=27015/tcp && \
    firewall-offline-cmd --add-service=cockpit && \
    firewall-offline-cmd --add-masquerade

RUN bootc container lint