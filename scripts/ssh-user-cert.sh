#!/usr/bin/env bash
#
# Obtain a short-lived SSH user certificate from OpenBao.
#
# Authenticate to the flake's `nixos` OpenBao namespace via OIDC (Authentik),
# then have the SSH CA sign your public key. The resulting certificate lets you
# log into any managed host as yourself — sshd trusts the CA via
# `TrustedUserCAKeys` (see modules/aspects/auth/ssh.nix). Password SSH auth is
# disabled, so this is the normal way in.
#
# The certificate's principal is your OIDC username — the `user` role's
# templated default_user resolves it server-side from your identity, so you
# cannot obtain a certificate for anyone else.
#
# The cert is written next to the key as `<key>-cert.pub`; OpenSSH picks it up
# automatically when you connect. Default TTL is 12h — re-run when it expires.
#
# Requires: `bao`, `ssh-keygen` on PATH.
#
# Usage:
#   scripts/ssh-user-cert.sh [path-to-private-key]   # default ~/.ssh/id_ed25519
set -euo pipefail

KEY="${1:-$HOME/.ssh/id_ed25519}"
BAO_ADDR="${BAO_ADDR:-https://secrets.singerfamily.ca}"
BAO_NAMESPACE="${BAO_NAMESPACE:-nixos}"
export BAO_ADDR BAO_NAMESPACE

if [[ ! -f "${KEY}.pub" ]]; then
  echo "no public key at ${KEY}.pub — generate one with: ssh-keygen -t ed25519" >&2
  exit 1
fi

if ! bao token lookup >/dev/null 2>&1; then
  echo "authenticating to $BAO_ADDR ($BAO_NAMESPACE) via OIDC" >&2
  bao login -method=oidc -no-print
fi

bao write -field=signed_key ssh/sign/user \
  public_key=@"${KEY}.pub" >"${KEY}-cert.pub"

echo "signed certificate written to ${KEY}-cert.pub"
ssh-keygen -L -f "${KEY}-cert.pub" | grep -E '(Valid|Principals|Extensions):' -A1
