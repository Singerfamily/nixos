#!/usr/bin/env bash
# Setup script to install pre-commit hooks
# Run this once after cloning or to reset hooks

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Installing pre-commit hooks..."

# Check if pre-commit is installed
if ! command -v pre-commit &>/dev/null; then
  echo -e "${YELLOW}pre-commit not found${NC}"
  echo "Enter the devshell first: nix develop"
  echo "pre-commit is included in the devshell packages."
  exit 1
fi

# Install the hooks
pre-commit install
pre-commit install --hook-type pre-push

echo -e "${GREEN}✓ Pre-commit hooks installed${NC}"
echo ""
echo "Hooks configuration: .pre-commit-config.yaml"
echo "Current hooks:"
pre-commit run --list || true

echo ""
echo "To test hooks on all files: pre-commit run --all-files"
echo "To skip hooks on next commit: git commit --no-verify"
