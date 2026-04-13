# GATEWAY API - CLUSTER SETUP
# Steps for GATEWAY API 
# GOAL 
# Cluster K33 (your clean VM)
# RKE2 server or agent cluster
# NO ingress controller
# Gateway API only
# Envoy Gateway
# Demo app exposed via HTTPRoute

Fresh Linux VM wiht sudo user adm-nejc and root

# **MASTER NODE**

sudo -i  # swithc to root
# --------------------- update system ----------------------------
apt update && apt upgrade -y

# -------------------- SYSTEM-WIDE ALIASES --------------------
cat > /etc/profile.d/custom-aliases.sh << 'EOF'
# Kubectl aliases
alias kubectl='kubecolor'
alias k='kubecolor'
alias K='kubecolor'

# General
alias cls='clear'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
EOF

chmod +x /etc/profile.d/custom-aliases.sh

# -------------------- INSTALLATION OF TOOLS --------------------
sudo apt update && sudo apt install -y \
  curl \
  git \
  socat \
  conntrack \
  ipset \
  iptables \
  jq \
  procps \
  btop \
  duf \
  kubecolor

# ------------------- PREPERATION -----------------------------

# Disable SWAP partitoin
swapoff -a
sed -i.bak '/ swap / s/^/#/' /etc/fstab
free -h # verify if it is disabled

# Disable firewall 
systemctl stop ufw || true
systemctl disable ufw || true

# Kernel settings - simple version
cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
overlay
EOF

modprobe br_netfilter
modprobe overlay

cat <<EOF | tee /etc/sysctl.d/99-kubernetes.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system

# Time sync - optional but good
timedatectl set-ntp true


# ------------------  RKE2 -----------------------
# Clean version
### NOTE : Here you have to change for every deployment - IP, ...

# ----- Config -------
mkdir -p /etc/rancher/rke2
cat > /etc/rancher/rke2/config.yaml << EOF
token: sPkEE3cYrG+UNFFon6xzgSUNA3E9MyGv76WL4g//uwKAcT978DEm69fXrKmz6tEA
cni: calico
disable:
  - rke2-ingress-nginx # IMPORTANT do disable !
tls-san:
$(for ip in "${TLS_SAN[@]}"; do echo "  - $ip"; done)
write-kubeconfig-mode: "0644"
node-taint:
  - "node-role.kubernetes.io/control-plane=true:NoSchedule"
EOF

# ------ INSTALL ------
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=server sh -
# Enable service
systemctl enable rke2-server
systemctl start rke2-server

systemctl status rke2-server


# --------------- KUBECTL -------------------------
# install kubectl
# -----------------------------------
echo 'export PATH=$PATH:/var/lib/rancher/rke2/bin' >> ~/.bashrc
echo 'export KUBECONFIG=/etc/rancher/rke2/rke2.yaml' >> ~/.bashrc
source ~/.bashrc

ln -sf /var/lib/rancher/rke2/bin/kubectl /usr/local/bin/kubectl

kubectl get nodes

# ---------------- WATCH ---------------------------
watch !!
# will use last commadn and watch it - in this case kubectl get nodes



