# GATEWAY API - CLUSTER SETUP
# **WORKER NODE**

sudo -i

apt update && apt upgrade -y

# ----------- INSTALL TOOLS ---------------
apt install -y \
  curl \
  git \
  socat \
  conntrack \
  ipset \
  iptables \
  jq \
  procps \
  btop \
  duf

# ------------------- PREPERATION -----------------------------

# Disable swap
swapoff -a
sed -i.bak '/ swap / s/^/#/' /etc/fstab
free -h

# Disable firewall
systemctl stop ufw || true
systemctl disable ufw || true

# Kernel preperation
cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
overlay
EOF

modprobe br_netfilter
modprobe overlay

# Network preperation
cat <<EOF | tee /etc/sysctl.d/99-kubernetes.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system

# Time sync
timedatectl set-ntp true

# ------------------  RKE2 -----------------------
# Clean version
### NOTE : Here you have to change for every deployment - IP, ...
# --- VARIABLES ---
MASTER_IP="10.189.26.11"
TOKEN="sPkEE3cYrG+UNFFon6xzgSUNA3E9MyGv76WL4g//uwKAcT978DEm69fXrKmz6tEA"

# ----- Config -------
mkdir -p /etc/rancher/rke2

cat <<EOF > /etc/rancher/rke2/config.yaml
server: https://$MASTER_IP:9345
token: $TOKEN
cni: calico
kubelet-arg:
  - "system-reserved=cpu=500m,memory=500Mi"
  - "kube-reserved=cpu=500m,memory=500Mi"
  - "eviction-hard=memory.available<500Mi"
EOF

# ------ INSTALL ------
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=agent sh -
# Enable service

systemctl enable rke2-agent
systemctl start rke2-agent

systemctl status rke2-agent
