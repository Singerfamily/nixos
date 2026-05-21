#!/usr/bin/env bash
#
# Mint the bootstrap credentials a new host needs to talk to OpenBao,
# producing the $SEED tree consumed by scripts/deploy.sh.
#
# Requires the running user's `bao` CLI to be authenticated against
# secrets.singerfamily.ca with permission to:
#   - write ssh/sign/host
#   - write pki/issue/host-client
#   - read  pki/cert/ca
#
# Produces under $SEED (default /tmp/deploy-seed):
#   ssh_host_ed25519_key            freshly generated host private key
#   ssh_host_ed25519_key.pub        host public key
#   ssh_host_ed25519_key-cert.pub   SSH host cert signed by ssh/roles/host
#   client.crt / client.key         TLS client cert from pki/roles/host-client
#   ca.crt                          OpenBao PKI root CA
#
# Usage:
#   scripts/provision-host.sh <hostname>            # writes to /tmp/deploy-seed
#   SEED=/path/to/seed scripts/provision-host.sh <hostname>
#
# The cert auth method on the OpenBao side trusts any client cert chained to
# the PKI root CA (see auth/cert/certs/host), so no per-host registration is
# required — issuing the cert is enough to gain `host` policy.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <hostname>" >&2
  exit 1
fi

HOST=$1
PRINCIPAL="${HOST}.singerfamily.ca"
SEED="${SEED:-/tmp/deploy-seed}"
BAO_ADDR="${BAO_ADDR:-https://secrets.singerfamily.ca}"
export BAO_ADDR

if ! bao token lookup >/dev/null 2>&1; then
  echo "bao CLI is not authenticated against $BAO_ADDR" >&2
  echo "run \`bao login\` (or set BAO_TOKEN) and retry" >&2
  exit 1
fi

install -d -m700 "$SEED"

# --- SSH host key + signed cert ---------------------------------------------
if [[ ! -f "$SEED/ssh_host_ed25519_key" ]]; then
  ssh-keygen -t ed25519 -N "" -C "${PRINCIPAL}" -f "$SEED/ssh_host_ed25519_key"
fi

bao write -field=signed_key ssh/sign/host \
  public_key=@"$SEED/ssh_host_ed25519_key.pub" \
  cert_type=host \
  valid_principals="${PRINCIPAL}" \
  > "$SEED/ssh_host_ed25519_key-cert.pub"

# --- OpenBao TLS client credentials -----------------------------------------
issue=$(bao write -format=json pki/issue/host-client \
  common_name="${PRINCIPAL}" \
  ttl=720h)

jq -r .data.certificate     <<<"$issue" > "$SEED/client.crt"
jq -r .data.private_key     <<<"$issue" > "$SEED/client.key"
jq -r .data.issuing_ca      <<<"$issue" > "$SEED/ca.crt"

chmod 600 "$SEED/client.key" "$SEED/ssh_host_ed25519_key"
chmod 644 "$SEED/client.crt" "$SEED/ca.crt" \
          "$SEED/ssh_host_ed25519_key.pub" "$SEED/ssh_host_ed25519_key-cert.pub"

cat <<EOF
seed for ${HOST} written to ${SEED}:
  $(ls -1 "$SEED" | sed 's/^/  /')

next: scripts/deploy.sh ${HOST} <flake-attr>
EOF
