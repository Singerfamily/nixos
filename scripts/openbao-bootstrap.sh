#!/usr/bin/env bash
#
# One-time bootstrap of the `nixos` OpenBao namespace.
#
# secrets.singerfamily.ca is a shared, multi-tenant OpenBao server. Everything
# this flake uses lives in its own `nixos` namespace so a leaked operator
# credential is confined to it (see scripts/provision-host.sh). This script
# stands that namespace up and is the in-repo record of its server-side state.
#
# Idempotent — safe to re-run; it skips anything already present.
#
# Runs in two stages:
#
#   Stage A (always): the SSH CA + host role, the `secret` KV store, the
#     `approle` auth method, and the `provision` operator policy. This is
#     everything scripts/provision-host.sh and the host agents need.
#
#   Stage B (only when the OIDC_* vars below are set): the `oidc` auth method
#     federated with Authentik, the `ssh-user` policy, the templated SSH `user`
#     role, and the `ssh-user` OIDC login role. This enables user
#     SSH-certificate auth. Operators authenticate via the root namespace's
#     OIDC method (the init/backup admin path) — there is deliberately no
#     operator login role in this namespace.
#
# Stage B prerequisite — an OAuth2/OpenID application in Authentik, then export:
#   OIDC_DISCOVERY_URL   e.g. https://auth.singerfamily.ca/application/o/openbao/
#   OIDC_CLIENT_ID
#   OIDC_CLIENT_SECRET
#
# Requires:
#   - `bao` CLI authenticated (token or OIDC) with sudo/admin on the `nixos`
#     namespace.
#   - `bao`, `jq` on PATH.
#
# Usage:
#   scripts/openbao-bootstrap.sh
set -euo pipefail

BAO_ADDR="${BAO_ADDR:-https://secrets.singerfamily.ca}"
BAO_NAMESPACE="${BAO_NAMESPACE:-nixos}"
export BAO_ADDR BAO_NAMESPACE

if ! bao token lookup >/dev/null 2>&1; then
  echo "bao CLI not authenticated against $BAO_ADDR ($BAO_NAMESPACE) — logging in via OIDC" >&2
  bao login -method=oidc -no-print
fi

secret_enabled() { bao secrets list -format=json | jq -e --arg p "$1/" '.[$p]' >/dev/null 2>&1; }
auth_enabled() { bao auth list -format=json | jq -e --arg p "$1/" '.[$p]' >/dev/null 2>&1; }

# ============================================================================
# Stage A — SSH CA, KV store, AppRole, operator policy
# ============================================================================

# --- SSH secret engine + CA -------------------------------------------------
if ! secret_enabled ssh; then
  echo "enabling ssh secret engine"
  bao secrets enable -path=ssh ssh
fi
if ! bao read ssh/config/ca >/dev/null 2>&1; then
  echo "generating ssh CA signing key"
  bao write ssh/config/ca generate_signing_key=true key_type=ssh-ed25519 >/dev/null
fi

# Host certificate role — hosts present a cert for <name>.singerfamily.ca,
# re-signed by the OpenBao agent (see modules/aspects/services/openbao-agent.nix).
bao write ssh/roles/host - >/dev/null <<'JSON'
{
  "key_type": "ca",
  "allow_host_certificates": true,
  "allow_user_certificates": false,
  "allowed_domains": "singerfamily.ca",
  "allow_subdomains": true,
  "allow_empty_principals": false,
  "ttl": "720h",
  "max_ttl": "720h"
}
JSON

# --- KV v2 store ------------------------------------------------------------
if ! secret_enabled secret; then
  echo "enabling secret kv-v2 store"
  bao secrets enable -path=secret -version=2 kv
fi

# --- AppRole auth method ----------------------------------------------------
if ! auth_enabled approle; then
  echo "enabling approle auth method"
  bao auth enable approle
fi

# --- provision policy -------------------------------------------------------
# The capability set scripts/provision-host.sh and scripts/rotate-host-creds.sh
# need: manage per-host AppRole roles, write the `host` policy, sign host
# certs. Scoped to the `nixos` namespace — a leaked operator token cannot
# touch root or other tenants.
bao policy write provision - <<'POLICY'
# Write the host agent policy.
path "sys/policies/acl/host" {
  capabilities = ["create", "read", "update", "delete"]
}
# Manage per-host AppRole roles and their credentials.
path "auth/approle/role/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
# Enable the approle method if a fresh namespace ever lacks it.
path "sys/auth" {
  capabilities = ["read"]
}
path "sys/auth/approle" {
  capabilities = ["create", "update", "sudo"]
}
# Sign SSH host certificates.
path "ssh/sign/host" {
  capabilities = ["create", "update"]
}
path "ssh/roles/*" {
  capabilities = ["read", "list"]
}
POLICY
echo "stage A complete"

# ============================================================================
# Stage B — OIDC auth + user SSH certificates
# ============================================================================

if [[ -z "${OIDC_CLIENT_ID:-}" || -z "${OIDC_CLIENT_SECRET:-}" || -z "${OIDC_DISCOVERY_URL:-}" ]]; then
  cat <<EOF

stage B skipped — set OIDC_DISCOVERY_URL, OIDC_CLIENT_ID and OIDC_CLIENT_SECRET
(from the Authentik application) and re-run.

SSH CA public key (commit into modules/aspects/auth/ssh.nix):
$(bao read -field=public_key ssh/config/ca)
EOF
  exit 0
fi

# --- OIDC auth method -------------------------------------------------------
if ! auth_enabled oidc; then
  echo "enabling oidc auth method"
  bao auth enable oidc
fi
bao write auth/oidc/config \
  oidc_discovery_url="$OIDC_DISCOVERY_URL" \
  oidc_client_id="$OIDC_CLIENT_ID" \
  oidc_client_secret="$OIDC_CLIENT_SECRET" \
  default_role="ssh-user" >/dev/null

OIDC_ACCESSOR=$(bao auth list -format=json | jq -r '."oidc/".accessor')

# --- ssh-user policy --------------------------------------------------------
bao policy write ssh-user - <<'POLICY'
# Sign a user SSH certificate. The `user` role templates the principal to the
# caller's own identity, so this cannot be used to impersonate another user.
path "ssh/sign/user" {
  capabilities = ["create", "update"]
}
POLICY

# --- SSH user certificate role ---------------------------------------------
# allowed_users and default_user are both templated to the caller's OIDC
# identity name: the cert's principal is resolved server-side to the caller's
# own username, and a request for any other principal is rejected.
# allow_empty_principals=false guarantees no cert is ever valid for all users.
bao write ssh/roles/user - >/dev/null <<JSON
{
  "key_type": "ca",
  "allow_user_certificates": true,
  "allow_host_certificates": false,
  "allowed_users_template": true,
  "allowed_users": "{{identity.entity.aliases.${OIDC_ACCESSOR}.name}}",
  "default_user_template": true,
  "default_user": "{{identity.entity.aliases.${OIDC_ACCESSOR}.name}}",
  "allow_empty_principals": false,
  "default_extensions": { "permit-pty": "" },
  "allowed_extensions": "permit-pty,permit-port-forwarding,permit-agent-forwarding",
  "ttl": "12h",
  "max_ttl": "24h"
}
JSON

# --- OIDC login role --------------------------------------------------------
# `preferred_username` becomes the identity alias name -> the SSH principal,
# so Authentik usernames must match the NixOS usernames (eric / clint).
# Single default role: every authenticated user may sign their own SSH cert.
CALLBACKS="http://localhost:8250/oidc/callback,${BAO_ADDR}/ui/vault/auth/oidc/oidc/callback"

bao write auth/oidc/role/ssh-user \
  user_claim="preferred_username" \
  allowed_redirect_uris="$CALLBACKS" \
  token_policies="ssh-user" \
  oidc_scopes="openid,profile,email" \
  ttl="12h" >/dev/null

cat <<EOF

bootstrap complete for namespace '${BAO_NAMESPACE}'.

SSH CA public key (commit into modules/aspects/auth/ssh.nix):
$(bao read -field=public_key ssh/config/ca)

next:
  - user SSH cert:  scripts/ssh-user-cert.sh
  (operators administer this namespace from a root-namespace OIDC login.)
EOF
