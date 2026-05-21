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
#   /etc/openbao/tls/client.crt|client.key   TLS client cert for OpenBao cert-auth
#   /etc/openbao/tls/ca.crt                  OpenBao PKI CA bundle
#
# Stage these under $SEED (default /tmp/deploy-seed) before running. The OpenBao
# agent renews the SSH cert and TLS client cert at runtime; this is bootstrap
# only — see modules/aspects/services/openbao-agent.nix.
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

# --- OpenBao TLS client credentials -----------------------------------------
install -d -m700 "$temp/etc/openbao/tls"
install -m600 "$SEED/client.key" "$temp/etc/openbao/tls/client.key"
install -m644 "$SEED/client.crt" "$temp/etc/openbao/tls/client.crt"
install -m644 "$SEED/ca.crt" "$temp/etc/openbao/tls/ca.crt"

ssh-keygen -R "$HOST"
ssh-copy-id "root@$HOST"

# Install NixOS to the host with the seeded credentials
nix run github:nix-community/nixos-anywhere -- \
  --extra-files "$temp" \
  --flake ".#$FLAKE_ATTR" \
  --target-host "root@$HOST" \
  --disko-mode mount \
  --phases kexec,disko,install
