#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "Error on line $LINENO" >&2' ERR

TARGET_USER="${SUDO_USER:-${USER:-moha}}"
# Attempt to detect the SSH client IP (host machine IP)
if [ -n "${SSH_CLIENT:-}" ]; then
  HOST_IP=$(echo "$SSH_CLIENT" | awk '{print $1}')
else
  HOST_IP="10.0.0.2" # Fallback
fi
GUEST_IP=$(ip route get 1 | awk '{print $7; exit}')

export DEBIAN_FRONTEND=noninteractive

# --- Basic packages ---
apt-get update -y
apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  git \
  python3 \
  python3-pip \
  python3-venv \
  build-essential \
  open-vm-tools \
  jq \
  ufw \
  unzip \
  mtr-tiny \
  wget

# --- Ensure target user exists ---
if ! id "${TARGET_USER}" &>/dev/null; then
  useradd -m -s /bin/bash "${TARGET_USER}"
fi

# --- Docker CE installation ---
if ! command -v docker >/dev/null 2>&1; then
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list

  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io
fi

usermod -aG docker "${TARGET_USER}"

# --- Docker Compose installation (standalone) ---
if ! command -v docker-compose >/dev/null 2>&1; then
  apt-get install -y docker-compose
fi

# --- Docker is used locally via socket only (Security refinement) ---
systemctl restart docker

# --- Terraform, Ansible, AWS CLI ---
if ! command -v terraform >/dev/null 2>&1; then
  curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /etc/apt/keyrings/hashicorp.gpg
  echo "deb [signed-by=/etc/apt/keyrings/hashicorp.gpg] \
https://apt.releases.hashicorp.com \
$(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/hashicorp.list
  apt-get update -y
  apt-get install -y terraform
fi

apt-get install -y ansible

if ! command -v aws >/dev/null 2>&1; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
  unzip -q /tmp/awscliv2.zip -d /tmp
  /tmp/aws/install
  rm -rf /tmp/aws /tmp/awscliv2.zip
fi

docker pull localstack/localstack:latest

# --- yq and lazygit ---
if ! command -v yq >/dev/null 2>&1; then
  YQ_VERSION="v4.40.5"
  wget "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64.tar.gz" -O - | tar xz
  mv yq_linux_amd64 /usr/bin/yq
fi

apt-get install -y direnv

if ! command -v lazygit >/dev/null 2>&1; then
  LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
    | jq -r .tag_name | sed 's/^v//')
  curl -Lo lazygit.tar.gz \
    "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  install lazygit /usr/local/bin
  rm -f lazygit lazygit.tar.gz
fi

# --- UFW firewall ---
ufw allow from "${HOST_IP}" to any port 22 proto tcp
ufw allow from "${HOST_IP}" to any port 5000 proto tcp
ufw allow from "${HOST_IP}" to any port 4566 proto tcp # LocalStack
ufw --force enable

# --- Python pip upgrades ---
python3 -m pip install --upgrade pip --break-system-packages || true
python3 -m pip install virtualenv --break-system-packages || true

# --- Bare Git repo for VM (test lab) ---
REPO_BASE="/home/${TARGET_USER}/repos"
APP_REPO="${REPO_BASE}/docker-flask-app.git"

mkdir -p "${REPO_BASE}"

if [ ! -d "${APP_REPO}" ]; then
  git init --bare "${APP_REPO}"
  chown -R "${TARGET_USER}:${TARGET_USER}" "${REPO_BASE}"
fi

# Note: Terraform provisioning is intentionally manual or triggered via CI/CD 
# following the "Author on Windows, Execute on Linux" pattern.
# See README.md for the development workflow.

echo "Bootstrap completed. Reboot recommended."
