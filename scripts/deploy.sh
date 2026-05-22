#!/usr/bin/env bash
#
# Remote NixOS install via nixos-anywhere.
#
# Seeds the new host with the credentials it needs before it can talk to
# OpenBao — all injected through nixos-anywhere --extra-files, never committed:
#
#   /etc/ssh/ssh_host_ed25519_key            host private key (sops age identity)
#   /etc/ssh/ssh_host_ed25519_key.pub        host public key
#   /etc/ssh/ssh_host_ed25519_key-cert.pub   initial SSH host cert (OpenBao SSH CA)
#   /etc/openbao/approle/role_id             AppRole role_id (per-host role)
#   /etc/openbao/approle/secret_id           AppRole secret_id (per-host role)
#
# Stage these under $SEED (default /tmp/deploy-seed) before running. The OpenBao
# agent rotates its own tokens at runtime; this is bootstrap only — see
# modules/aspects/services/openbao-agent.nix.
set -euo pipefail

SEED="${SEED:-/tmp/deploy-seed}"

HOST=$1
FLAKE_ATTR=$2

# Create a temporary directory for the extra-files tree
temp=$(mktemp -d)
cleanup() { rm -rf "$temp"; }
trap cleanup EXIT

# --- SSH host key + certificate ---------------------------------------------
install -d -m755 "$temp/etc/ssh"
install -m600 "$SEED/ssh_host_ed25519_key" "$temp/etc/ssh/ssh_host_ed25519_key"
install -m644 "$SEED/ssh_host_ed25519_key.pub" "$temp/etc/ssh/ssh_host_ed25519_key.pub"
install -m644 "$SEED/ssh_host_ed25519_key-cert.pub" "$temp/etc/ssh/ssh_host_ed25519_key-cert.pub"

# --- OpenBao AppRole credentials --------------------------------------------
install -d -m700 "$temp/etc/openbao/approle"
install -m600 "$SEED/role_id" "$temp/etc/openbao/approle/role_id"
install -m600 "$SEED/secret_id" "$temp/etc/openbao/approle/secret_id"

ssh-keygen -R "$HOST"
ssh-copy-id -o StrictHostKeyChecking=accept-new "root@$HOST"

# Install NixOS to the host with the seeded credentials
nix run github:nix-community/nixos-anywhere -- \
  --extra-files "$temp" \
  --flake ".#$FLAKE_ATTR" \
  --target-host "root@$HOST" \
  --disko-mode mount \
  --phases kexec,disko,install,reboot
