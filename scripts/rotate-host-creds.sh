#!/usr/bin/env bash
#
# Rotate a host's OpenBao AppRole credentials — run this when a host's
# role_id/secret_id may have leaked.
#
# Steps, in order:
#   1. Destroy EVERY existing secret_id for the host's role — a leaked
#      secret_id is only contained once it's destroyed server-side.
#   2. Rotate the role_id and mint a fresh secret_id. On a leak we assume
#      the role_id is compromised alongside the secret_id, so both change.
#   3. Deliver the new role_id + secret_id to the running host over SSH and
#      restart the OpenBao agent so it re-authenticates immediately.
#
# The host's per-host role (host-<hostname>) must already exist — run
# scripts/provision-host.sh first for a brand-new host. Because this only
# touches AppRole credentials, the host stays up; no redeploy is needed.
#
# Auth: uses an existing `bao` token if one is present; otherwise falls back
# to an interactive `bao login -method=oidc` (browser flow).
#
# Requires:
#   - `bao` CLI able to authenticate against secrets.singerfamily.ca with
#     permission to manage auth/approle/role/host-<hostname>.
#   - SSH access to the target host as root, or as a user with passwordless
#     sudo (privileged steps below are run through `sudo`).
#   - `bao`, `jq` on PATH (all in nixpkgs).
#
# Usage:
#   scripts/rotate-host-creds.sh <hostname> [ssh-target]
#     ssh-target defaults to root@<hostname>.singerfamily.ca
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "usage: $0 <hostname> [ssh-target]" >&2
  exit 1
fi

HOST=$1
TARGET="${2:-root@${HOST}.singerfamily.ca}"
ROLE="host-${HOST}"
BAO_ADDR="${BAO_ADDR:-https://secrets.singerfamily.ca}"
BAO_NAMESPACE="${BAO_NAMESPACE:-nixos}"
export BAO_ADDR BAO_NAMESPACE

# Use an existing token if valid; otherwise fall back to OIDC (browser flow).
if ! bao token lookup >/dev/null 2>&1; then
  echo "bao CLI not authenticated against $BAO_ADDR — logging in via OIDC" >&2
  bao login -method=oidc -no-print
fi

if ! bao read "auth/approle/role/${ROLE}" >/dev/null 2>&1; then
  echo "role ${ROLE} does not exist — run scripts/provision-host.sh ${HOST} first" >&2
  exit 1
fi

# --- 1. Destroy every existing secret_id for the role -----------------------
mapfile -t ACCESSORS < <(
  bao list -format=json "auth/approle/role/${ROLE}/secret-id" 2>/dev/null |
    jq -r '.[]' || true
)
for acc in "${ACCESSORS[@]}"; do
  [[ -n "$acc" ]] || continue
  bao write "auth/approle/role/${ROLE}/secret-id-accessor/destroy" \
    secret_id_accessor="$acc" >/dev/null
done
echo "destroyed ${#ACCESSORS[@]} existing secret_id(s) for ${ROLE}"

# --- 2. Rotate role_id and mint a fresh secret_id ---------------------------
bao write "auth/approle/role/${ROLE}/role-id" \
  role_id="$(cat /proc/sys/kernel/random/uuid)" >/dev/null
ROLE_ID=$(bao read -field=role_id "auth/approle/role/${ROLE}/role-id")
SECRET_ID=$(bao write -field=secret_id -f "auth/approle/role/${ROLE}/secret-id")

# --- 3. Deliver to the running host -----------------------------------------
# Privileged steps go through sudo so a non-root SSH user (e.g. recovery)
# with passwordless sudo works as well as root.
ssh "$TARGET" 'sudo install -d -m700 /etc/openbao/approle'
printf '%s' "$ROLE_ID" |
  ssh "$TARGET" 'sudo tee /etc/openbao/approle/role_id >/dev/null &&
    sudo chmod 600 /etc/openbao/approle/role_id'
printf '%s' "$SECRET_ID" |
  ssh "$TARGET" 'sudo tee /etc/openbao/approle/secret_id >/dev/null &&
    sudo chmod 600 /etc/openbao/approle/secret_id'
ssh "$TARGET" 'sudo systemctl restart vault-agent-openbao.service'

cat <<EOF

rotated OpenBao credentials for ${HOST}:
  role:    ${ROLE}
  target:  ${TARGET}
  agent:   vault-agent-openbao.service restarted

the old role_id and all old secret_ids are now invalid.
EOF
