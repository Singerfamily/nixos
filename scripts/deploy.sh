#!/usr/bin/env bash

# Create a temporary directory
temp=$(mktemp -d)

# Function to cleanup temporary directory on exit
cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT

# Create the directory where sshd expects to find the host keys
install -d -m755 "$temp/etc/ssh"

# Decrypt your private key from the password store and copy it to the temporary directory
# pass ssh_host_ed25519_key > "$temp/etc/ssh/ssh_host_ed25519_key"
cp /tmp/ssh/ssh_host_ed25519_key $temp/etc/ssh/ssh_host_ed25519_key

# Set the correct permissions so sshd will accept the key
chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

HOST=$1

ssh-keygen -R $1

ssh-copy-id root@$1

# Install NixOS to the host system with our secrets
nix run github:nix-community/nixos-anywhere -- --extra-files "$temp" --flake ".#$2" --target-host root@$HOST --disko-mode mount --phases kexec,disko,install
