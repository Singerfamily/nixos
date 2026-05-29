#!/usr/bin/env bash
#
# Unified host deploy: stand up credentials, provision the host, install NixOS.
#
# This is the single entrypoint for bringing a managed host online. It runs
# three phases in order so a host is never deployed in a state where it can't
# decrypt its own activation secrets:
#
#   bootstrap  (opt-in, --bootstrap)  one-time server-side setup of the `nixos`
#              OpenBao namespace: SSH CA, KV store, AppRole auth, operator
#              policy, and (when OIDC_* is set) OIDC user-cert auth. Idempotent;
#              you only need it once per namespace, not per host. Pass --bootstrap
#              with no host to run this alone (prints the SSH CA public key).
#
#   provision  generate the host SSH key, enroll its age recipient into
#              .sops.yaml + re-encrypt modules/secrets/sops/bootstrap.yaml,
#              ensure the per-host OpenBao AppRole role, and mint the runtime
#              credentials (SSH host cert + role_id/secret_id) into $SEED.
#
#   commit     auto-commit the .sops.yaml / bootstrap.yaml mutations (and the
#              host module if present) so the nixos-anywhere flake build sees
#              the new decryption recipient. Skipped if nothing changed.
#
#   install    ship the seeded credentials via nixos-anywhere --extra-files
#              (never committed) and install over kexec+disko. Destructive.
#
# Each host gets its own AppRole role so a leaked credential can be revoked in
# isolation — see scripts/rotate-host-creds.sh. The host's flake attribute is
# assumed to equal its hostname (event-horizon, clint-pc, nebula, ...).
#
# Auth: uses an existing `bao` token if present; otherwise falls back to an
# interactive `bao login -method=oidc` (browser flow). All `bao` calls target
# the `nixos` namespace.
#
# Requires on PATH: bao, jq, ssh-to-age, sops, ssh-keygen, ssh-copy-id, git
# (all in nixpkgs / the devshell). The running user's age key must already be a
# recipient of bootstrap.yaml (eric / clint) so sops can re-encrypt it.
#
# Bootstrap stage B (OIDC user certs) needs an Authentik OAuth2/OpenID app:
#   export OIDC_DISCOVERY_URL OIDC_CLIENT_ID OIDC_CLIENT_SECRET
#
# Produces under $SEED (default /tmp/deploy-seed):
#   ssh_host_ed25519_key            host private key (also feeds sops age id)
#   ssh_host_ed25519_key.pub        host public key
#   ssh_host_ed25519_key-cert.pub   SSH host cert signed by ssh/roles/host
#   role_id / secret_id             AppRole credentials for the per-host role
#
# Usage:
#   scripts/deploy.sh <hostname> <host-ip>        # provision + commit + install
#   scripts/deploy.sh --bootstrap                 # namespace setup only
#   scripts/deploy.sh --bootstrap <host> <ip>     # bootstrap (idempotent) + deploy
#   SEED=/path/to/seed scripts/deploy.sh <host> <ip>
set -euo pipefail

# ============================================================================
# Argument parsing
# ============================================================================
BOOTSTRAP=0
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --bootstrap) BOOTSTRAP=1; shift ;;
    -h | --help)
      sed -n '2,/^set -euo/p' "$0" | sed 's/^# \?//;$d'
      exit 0
      ;;
    -*) echo "unknown option: $1" >&2; exit 1 ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

if [[ ${#POSITIONAL[@]} -eq 0 && $BOOTSTRAP -eq 0 ]]; then
  echo "usage: $0 [--bootstrap] [<hostname> <host-ip>]" >&2
  exit 1
fi
if [[ ${#POSITIONAL[@]} -eq 1 || ${#POSITIONAL[@]} -gt 2 ]]; then
  echo "usage: $0 [--bootstrap] [<hostname> <host-ip>]" >&2
  exit 1
fi

HOST="${POSITIONAL[0]:-}"
HOST_IP="${POSITIONAL[1]:-}"

SEED="${SEED:-/tmp/deploy-seed}"
BAO_ADDR="${BAO_ADDR:-https://secrets.singerfamily.ca}"
BAO_NAMESPACE="${BAO_NAMESPACE:-nixos}"
export BAO_ADDR BAO_NAMESPACE

REPO_ROOT=$(git rev-parse --show-toplevel)
SOPS_YAML="${REPO_ROOT}/.sops.yaml"
BOOTSTRAP_YAML="${REPO_ROOT}/modules/secrets/sops/bootstrap.yaml"

# ============================================================================
# Helpers
# ============================================================================
require() {
  local miss=0
  for bin in "$@"; do
    command -v "$bin" >/dev/null 2>&1 || { echo "missing required tool: $bin" >&2; miss=1; }
  done
  [[ $miss -eq 0 ]] || { echo "enter the devshell (nix develop) and retry" >&2; exit 1; }
}

bao_login() {
  if ! bao token lookup >/dev/null 2>&1; then
    echo "bao CLI not authenticated against $BAO_ADDR ($BAO_NAMESPACE) — logging in via OIDC" >&2
    bao login -method=oidc -no-print
  fi
}

secret_enabled() { bao secrets list -format=json | jq -e --arg p "$1/" '.[$p]' >/dev/null 2>&1; }
auth_enabled() { bao auth list -format=json | jq -e --arg p "$1/" '.[$p]' >/dev/null 2>&1; }

# ============================================================================
# Phase: bootstrap — one-time `nixos` namespace setup
# ============================================================================
# secrets.singerfamily.ca is a shared, multi-tenant OpenBao server. Everything
# this flake uses lives in its own `nixos` namespace so a leaked operator
# credential is confined to it. Idempotent — skips anything already present.
do_bootstrap() {
  echo "== bootstrap: ${BAO_NAMESPACE} namespace =="

  # --- SSH secret engine + CA -----------------------------------------------
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

  # User certificate role (host-agent path) — the host's AppRole calls this to
  # sign short-lived user certs for users declared on the host. allowed_users="*"
  # because per-host scoping is enforced on the accepting side via
  # AuthorizedPrincipalsFile (see modules/aspects/auth/ssh.nix).
  bao write ssh/roles/user-host - >/dev/null <<'JSON'
{
  "key_type": "ca",
  "allow_user_certificates": true,
  "allow_host_certificates": false,
  "allowed_users": "*",
  "allow_empty_principals": false,
  "default_extensions": {
    "permit-pty": "",
    "permit-port-forwarding": "",
    "permit-agent-forwarding": ""
  },
  "ttl": "12h",
  "max_ttl": "12h"
}
JSON

  # --- KV v2 store ----------------------------------------------------------
  if ! secret_enabled secret; then
    echo "enabling secret kv-v2 store"
    bao secrets enable -path=secret -version=2 kv
  fi

  # --- AppRole auth method --------------------------------------------------
  if ! auth_enabled approle; then
    echo "enabling approle auth method"
    bao auth enable approle
  fi

  # --- provision policy -----------------------------------------------------
  # The capability set the provision phase below and scripts/rotate-host-creds.sh
  # need: manage per-host AppRole roles, write the `host` policy, sign host
  # certs. Scoped to the `nixos` namespace.
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
  echo "bootstrap stage A complete"

  # --- Stage B — OIDC auth + user SSH certificates --------------------------
  if [[ -z "${OIDC_CLIENT_ID:-}" || -z "${OIDC_CLIENT_SECRET:-}" || -z "${OIDC_DISCOVERY_URL:-}" ]]; then
    echo "bootstrap stage B skipped — set OIDC_DISCOVERY_URL, OIDC_CLIENT_ID, OIDC_CLIENT_SECRET to enable user SSH certs" >&2
  else
    if ! auth_enabled oidc; then
      echo "enabling oidc auth method"
      bao auth enable oidc
    fi
    bao write auth/oidc/config \
      oidc_discovery_url="$OIDC_DISCOVERY_URL" \
      oidc_client_id="$OIDC_CLIENT_ID" \
      oidc_client_secret="$OIDC_CLIENT_SECRET" \
      default_role="ssh-user" >/dev/null

    local oidc_accessor
    oidc_accessor=$(bao auth list -format=json | jq -r '."oidc/".accessor')

    # ssh-user policy — sign a user SSH cert. The `user` role templates the
    # principal to the caller's own identity, so it can't impersonate anyone.
    bao policy write ssh-user - <<'POLICY'
path "ssh/sign/user" {
  capabilities = ["create", "update"]
}
POLICY

    # SSH user certificate role — allowed_users/default_user templated to the
    # caller's OIDC identity name; a request for any other principal is rejected.
    bao write ssh/roles/user - >/dev/null <<JSON
{
  "key_type": "ca",
  "allow_user_certificates": true,
  "allow_host_certificates": false,
  "allowed_users_template": true,
  "allowed_users": "{{identity.entity.aliases.${oidc_accessor}.name}}",
  "default_user_template": true,
  "default_user": "{{identity.entity.aliases.${oidc_accessor}.name}}",
  "allow_empty_principals": false,
  "default_extensions": { "permit-pty": "" },
  "allowed_extensions": "permit-pty,permit-port-forwarding,permit-agent-forwarding",
  "ttl": "12h",
  "max_ttl": "24h"
}
JSON

    # OIDC login role — preferred_username becomes the SSH principal, so
    # Authentik usernames must match NixOS usernames (eric / clint).
    local callbacks="http://localhost:8250/oidc/callback,${BAO_ADDR}/ui/vault/auth/oidc/oidc/callback"
    bao write auth/oidc/role/ssh-user \
      user_claim="preferred_username" \
      allowed_redirect_uris="$callbacks" \
      token_policies="ssh-user" \
      oidc_scopes="openid,profile,email" \
      ttl="12h" >/dev/null
    echo "bootstrap stage B complete"
  fi

  cat <<EOF

SSH CA public key (commit into modules/aspects/auth/ssh.nix):
$(bao read -field=public_key ssh/config/ca)
EOF
}

# ============================================================================
# Phase: provision — per-host keys, sops enrollment, AppRole, runtime creds
# ============================================================================
do_provision() {
  local principal="${HOST}.singerfamily.ca"
  local role="host-${HOST}"

  echo "== provision: ${HOST} =="
  install -d -m700 "$SEED"

  # --- 1. SSH host key ------------------------------------------------------
  if [[ ! -f "$SEED/ssh_host_ed25519_key" ]]; then
    ssh-keygen -t ed25519 -N "" -C "${principal}" -f "$SEED/ssh_host_ed25519_key"
  fi

  # --- 2. Wire host into sops -----------------------------------------------
  local age_key
  age_key=$(ssh-to-age <"$SEED/ssh_host_ed25519_key.pub")
  echo "host ${HOST} age recipient: ${age_key}"

  if grep -q "&${HOST} " "$SOPS_YAML"; then
    echo "  .sops.yaml already declares &${HOST}; leaving as-is" >&2
  else
    # Insert the new host anchor after the last `- &<host> age1...` line in the
    # top-level keys: block, and append `- *<host>` to every age list inside a
    # bootstrap.yaml creation_rule.
    awk -v host="$HOST" -v age="$age_key" '
      BEGIN { anchor_re = "^[[:space:]]+- &[A-Za-z0-9_-]+ age1[a-z0-9]+[[:space:]]*$" }
      { lines[NR] = $0 }
      $0 ~ anchor_re { last_anchor = NR }
      END {
        n = NR
        for (i = 1; i <= n; i++) {
          out[++m] = lines[i]
          if (i == last_anchor) out[++m] = "  - &" host " " age
        }
        in_boot = 0; in_age = 0; ref_indent = "          "
        for (i = 1; i <= m; i++) {
          line = out[i]
          if (line ~ /path_regex:[[:space:]]*modules\/secrets\/sops\/bootstrap\.yaml/) {
            in_boot = 1; in_age = 0
          } else if (in_boot && line ~ /^[[:space:]]+- path_regex:/) {
            in_boot = 0; in_age = 0
          }
          if (in_boot && line ~ /^[[:space:]]+- age:[[:space:]]*$/) {
            in_age = 1
            print line
            continue
          }
          if (in_age) {
            if (line ~ /^[[:space:]]+- \*/) {
              match(line, /^[[:space:]]+/)
              ref_indent = substr(line, 1, RLENGTH)
              print line
              continue
            }
            print ref_indent "- *" host
            in_age = 0
          }
          print line
        }
        if (in_age) print ref_indent "- *" host
      }
    ' "$SOPS_YAML" >"${SOPS_YAML}.tmp"
    mv "${SOPS_YAML}.tmp" "$SOPS_YAML"
  fi

  # Re-encrypt bootstrap.yaml so the new host can decrypt it on first boot.
  # `sops updatekeys` reads .sops.yaml; the current user must already be a
  # recipient (so their age key can decrypt the existing payload).
  sops updatekeys -y "$BOOTSTRAP_YAML"

  # --- 3. Ensure OpenBao server-side config ---------------------------------
  # AppRole auth method — normally enabled by the bootstrap phase; fallback if
  # the namespace was set up by hand.
  if ! bao auth list -format=json | jq -e '."approle/"' >/dev/null 2>&1; then
    echo "enabling approle auth method"
    bao auth enable approle
  fi

  # Shared `host` policy — the capability set every managed host's agent needs.
  # Written every run so it stays in sync with the agent's templates
  # (see modules/aspects/services/openbao-agent.nix).
  bao policy write host - <<'POLICY'
# SSH host certificate signing.
path "ssh/sign/host" {
  capabilities = ["create", "update"]
}
# Fixed system secrets rendered by the agent (SSSD, Authentik, GitHub token).
path "secret/data/authentik/ldap-service-account" {
  capabilities = ["read"]
}
path "secret/data/authentik/ldap-outpost-token" {
  capabilities = ["read"]
}
# OIDC device-code login client credentials (opt-in oidc-login aspect).
path "secret/data/authentik/oidc-pam" {
  capabilities = ["read"]
}
path "secret/data/hosts/github-flake-token" {
  capabilities = ["read"]
}
# Declarative secrets via openbao.secrets / home-manager openbao.secrets.
# system secrets live under secret/data/system/, user secrets under
# secret/data/users/<username>/.
path "secret/data/system/*" {
  capabilities = ["read"]
}
path "secret/data/users/*" {
  capabilities = ["read"]
}
# Host-agent user cert signing (ssh/roles/user-host).
# Scoping is enforced by AuthorizedPrincipalsFile on the accepting host.
path "ssh/sign/user-host" {
  capabilities = ["create", "update"]
}
POLICY

  # Per-host AppRole role. One role per host so a leaked credential can be
  # revoked in isolation (scripts/rotate-host-creds.sh) without touching other
  # hosts. secret_id has no TTL or use limit: the agent keeps it on disk and
  # re-logs in after every reboot.
  bao write "auth/approle/role/${role}" \
    token_policies=host \
    secret_id_ttl=0 \
    secret_id_num_uses=0

  # --- 4. OpenBao runtime credentials ---------------------------------------
  # SSH host cert (signed by the OpenBao SSH CA, valid for ssh/roles/host).
  bao write -field=signed_key ssh/sign/host \
    public_key=@"$SEED/ssh_host_ed25519_key.pub" \
    cert_type=host \
    valid_principals="${principal}" \
    >"$SEED/ssh_host_ed25519_key-cert.pub"

  # AppRole credentials. role_id is stable per role and safe to fetch on every
  # run; secret_id is freshly minted and dropped into the seed for the install
  # phase to ship.
  bao read -field=role_id "auth/approle/role/${role}/role-id" >"$SEED/role_id"
  bao write -field=secret_id -f "auth/approle/role/${role}/secret-id" >"$SEED/secret_id"

  chmod 600 "$SEED/secret_id" "$SEED/role_id" "$SEED/ssh_host_ed25519_key"
  chmod 644 "$SEED/ssh_host_ed25519_key.pub" "$SEED/ssh_host_ed25519_key-cert.pub"
  echo "provisioning complete — seed at ${SEED}"
}

# ============================================================================
# Phase: commit — land the sops mutations before the flake build
# ============================================================================
# nixos-anywhere builds the flake from the git tree, so the new age recipient
# in .sops.yaml / bootstrap.yaml must be committed first.
do_commit() {
  echo "== commit: sops enrollment for ${HOST} =="
  local host_dir="${REPO_ROOT}/modules/hosts/${HOST}"
  git -C "$REPO_ROOT" add "$SOPS_YAML" "$BOOTSTRAP_YAML"
  [[ -d "$host_dir" ]] && git -C "$REPO_ROOT" add "$host_dir"

  if git -C "$REPO_ROOT" diff --cached --quiet; then
    echo "  nothing to commit — host already enrolled"
    return
  fi
  git -C "$REPO_ROOT" commit -m "Provision host ${HOST}"
}

# ============================================================================
# Phase: install — nixos-anywhere with seeded credentials
# ============================================================================
# Seeds the new host with the credentials it needs before it can talk to
# OpenBao — all injected through --extra-files, never committed. The OpenBao
# agent rotates its own tokens at runtime; this is bootstrap only (see
# modules/aspects/services/openbao-agent.nix).
do_install() {
  echo "== install: ${HOST} (${HOST_IP}) =="

  local temp
  temp=$(mktemp -d)
  trap 'rm -rf "$temp"' EXIT

  # SSH host key + certificate -> sops age identity + initial host cert.
  install -d -m755 "$temp/etc/ssh"
  install -m600 "$SEED/ssh_host_ed25519_key" "$temp/etc/ssh/ssh_host_ed25519_key"
  install -m644 "$SEED/ssh_host_ed25519_key.pub" "$temp/etc/ssh/ssh_host_ed25519_key.pub"
  install -m644 "$SEED/ssh_host_ed25519_key-cert.pub" "$temp/etc/ssh/ssh_host_ed25519_key-cert.pub"

  # OpenBao AppRole credentials (per-host role).
  install -d -m700 "$temp/etc/openbao/approle"
  install -m600 "$SEED/role_id" "$temp/etc/openbao/approle/role_id"
  install -m600 "$SEED/secret_id" "$temp/etc/openbao/approle/secret_id"

  ssh-keygen -R "$HOST_IP"
  ssh-copy-id -o StrictHostKeyChecking=accept-new "root@$HOST_IP"

  nix run github:nix-community/nixos-anywhere -- \
    --extra-files "$temp" \
    --flake ".#${HOST}" \
    --target-host "root@$HOST_IP" \
    --disko-mode mount \
    --phases kexec,disko,install,reboot
}

# ============================================================================
# Main
# ============================================================================
require bao jq git
bao_login

if [[ $BOOTSTRAP -eq 1 ]]; then
  do_bootstrap
fi

# Bootstrap-only invocation (no host given).
if [[ ${#POSITIONAL[@]} -eq 0 ]]; then
  exit 0
fi

require ssh-to-age sops ssh-keygen ssh-copy-id
do_provision
do_commit
do_install

cat <<EOF

deploy complete for ${HOST} (${HOST_IP}).
  user SSH cert:  scripts/ssh-user-cert.sh
  rotate creds:   scripts/rotate-host-creds.sh ${HOST}
EOF
