#!/usr/bin/env bash
set -Eeuo pipefail

TARGET_USER="${SUDO_USER:-${USER:-moha}}"

# Explicitly cleanup LocalStack container first
if command -v docker >/dev/null 2>&1; then
  echo "Stopping and removing LocalStack container..."
  docker stop localstack 2>/dev/null || true
  docker rm localstack 2>/dev/null || true
fi

if command -v docker >/dev/null 2>&1; then
  systemctl stop docker.service docker.socket 2>/dev/null || true
  apt-get purge -y \
    docker-ce \
    docker-ce-cli \
    docker-ce-rootless-extras \
    docker-buildx-plugin \
    docker-compose-plugin \
    docker.io \
    containerd.io || true

  rm -rf \
    /var/lib/docker \
    /var/lib/containerd \
    /etc/docker

  rm -f \
    /etc/apt/sources.list.d/docker.list \
    /etc/apt/keyrings/docker.gpg \
    /etc/systemd/system/docker.service.d/override.conf
fi

if command -v terraform >/dev/null 2>&1; then
  apt-get purge -y terraform
  rm -f \
    /etc/apt/sources.list.d/hashicorp.list \
    /etc/apt/keyrings/hashicorp.gpg
fi

if command -v ansible >/dev/null 2>&1; then
  apt-get purge -y ansible
fi

if [ -x /usr/local/bin/aws ]; then
  rm -rf /usr/local/aws-cli
  rm -f \
    /usr/local/bin/aws \
    /usr/local/bin/aws_completer
fi

rm -f \
  /usr/bin/yq \
  /usr/local/bin/lazygit

apt-get purge -y direnv || true

rm -rf \
  "$HOME/.ansible" \
  "$HOME/.terraform.d"

# Cleanup Terraform state files in current directory if running from repo
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
rm -rf envs/dev/.terraform envs/dev/.terraform.lock.hcl envs/dev/terraform.tfstate envs/dev/terraform.tfstate.backup

apt-get autoremove -y
apt-get clean

if command -v ufw >/dev/null 2>&1; then
  echo "y" | ufw reset
  ufw disable
fi

rm -rf "/home/${TARGET_USER}/repos"

echo "Purge completed."
