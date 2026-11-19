#!/usr/bin/env bash
set -Eeuo pipefail

if command -v docker >/dev/null 2>&1; then
  echo "Stopping and removing containers via compose..."
  docker compose down -v --remove-orphans 2>/dev/null || true
  
  # Prune volumes to ensure clean state for LocalStack
  docker system prune -f
fi

rm -rf \
  "$HOME/.ansible" \
  "$HOME/.terraform.d"

# Reset Terraform State
echo "Cleaning Terraform state..."
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
rm -rf envs/dev/.terraform envs/dev/.terraform.lock.hcl envs/dev/terraform.tfstate envs/dev/terraform.tfstate.backup

echo "Lab environment reset."
