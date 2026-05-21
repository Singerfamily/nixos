#!/usr/bin/env bash
#
# One-shot host provisioning. Run this BEFORE committing a new host and BEFORE
# running scripts/deploy.sh. It produces everything the new host needs to come
# up fully managed (sops-nix + OpenBao agent) on first boot — so we never
# deploy a host that can't decrypt its own activation secrets.
#
# Steps, in order:
#   1. Generate the host's SSH host key (idempotent).
#   2. Derive the host's age recipient (ssh-to-age) and wire it into
#      .sops.yaml + re-encrypt modules/secrets/sops/bootstrap.yaml so the new
#      host is a decryption recipient. THIS REWRITES TRACKED FILES — commit
#      them before deploying so the flake build sees the updated recipients.
#   3. Mint runtime credentials from OpenBao (SSH host cert + AppRole
#      secret_id) into $SEED for scripts/deploy.sh to ship via --extra-files.
#
# Requires:
#   - `bao` CLI authenticated against secrets.singerfamily.ca with permission
#     to write ssh/sign/host, read auth/approle/role/host/role-id, and write
#     auth/approle/role/host/secret-id, read pki/cert/ca.
#   - A working sops setup locally — the running user's age key must already
#     be a recipient of bootstrap.yaml (esinger / csinger).
#   - `ssh-to-age`, `sops`, `jq` on PATH (all in nixpkgs).
#
# Produces under $SEED (default /tmp/deploy-seed):
#   ssh_host_ed25519_key            host private key (also feeds sops age id)
#   ssh_host_ed25519_key.pub        host public key
#   ssh_host_ed25519_key-cert.pub   SSH host cert signed by ssh/roles/host
#   role_id / secret_id             AppRole credentials for the `host` role
#   ca.crt                          OpenBao PKI root CA
#
# Usage:
#   scripts/provision-host.sh <hostname>            # writes to /tmp/deploy-seed
#   SEED=/path/to/seed scripts/provision-host.sh <hostname>
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

REPO_ROOT=$(git rev-parse --show-toplevel)
SOPS_YAML="${REPO_ROOT}/.sops.yaml"
BOOTSTRAP_YAML="${REPO_ROOT}/modules/secrets/sops/bootstrap.yaml"

if ! bao token lookup >/dev/null 2>&1; then
  echo "bao CLI is not authenticated against $BAO_ADDR" >&2
  echo 'run `bao login` (or set BAO_TOKEN) and retry' >&2
  exit 1
fi

install -d -m700 "$SEED"

# --- 1. SSH host key --------------------------------------------------------
if [[ ! -f "$SEED/ssh_host_ed25519_key" ]]; then
  ssh-keygen -t ed25519 -N "" -C "${PRINCIPAL}" -f "$SEED/ssh_host_ed25519_key"
fi

# --- 2. Wire host into sops -------------------------------------------------
AGE_KEY=$(ssh-to-age <"$SEED/ssh_host_ed25519_key.pub")
echo "host ${HOST} age recipient: ${AGE_KEY}"

if grep -q "&${HOST} " "$SOPS_YAML"; then
  echo "  .sops.yaml already declares &${HOST}; leaving as-is" >&2
else
  # Insert the new host anchor right after the last `- &<host> age1...` line
  # in the top-level `keys:` block, and append `- *<host>` to every age list
  # inside a bootstrap.yaml creation_rule.
  awk -v host="$HOST" -v age="$AGE_KEY" '
    BEGIN { anchor_re = "^[[:space:]]+- &[A-Za-z0-9_-]+ age1[a-z0-9]+[[:space:]]*$" }
    # Buffer everything so we can mutate before emit.
    { lines[NR] = $0 }
    $0 ~ anchor_re { last_anchor = NR }
    END {
      # Pass 1: insert anchor after last existing host anchor in keys: block.
      n = NR
      for (i = 1; i <= n; i++) {
        out[++m] = lines[i]
        if (i == last_anchor) out[++m] = "  - &" host " " age
      }

      # Pass 2: walk the output, append `- *host` to each bootstrap age list.
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
          # End of age list — emit ref before this line.
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

# --- 3. OpenBao runtime credentials -----------------------------------------
# SSH host cert (signed by the OpenBao SSH CA, valid for ssh/roles/host).
bao write -field=signed_key ssh/sign/host \
  public_key=@"$SEED/ssh_host_ed25519_key.pub" \
  cert_type=host \
  valid_principals="${PRINCIPAL}" \
  >"$SEED/ssh_host_ed25519_key-cert.pub"

# AppRole credentials for the `host` role. role_id is stable per role and
# safe to fetch on every run; secret_id is freshly minted (one-time-use
# unless the role's secret_id_num_uses > 1) and dropped into the seed for
# scripts/deploy.sh to ship.
bao read -field=role_id auth/approle/role/host/role-id >"$SEED/role_id"
bao write -field=secret_id -f auth/approle/role/host/secret-id >"$SEED/secret_id"

# OpenBao PKI root CA — used by the agent to verify the OpenBao server's
# TLS cert. (Traefik also presents a publicly-trusted cert, so this is
# defense-in-depth; ca_cert is configured in modules/aspects/services/
# openbao-agent.nix.)
bao read -field=certificate pki/cert/ca >"$SEED/ca.crt"

chmod 600 "$SEED/secret_id" "$SEED/role_id" "$SEED/ssh_host_ed25519_key"
chmod 644 "$SEED/ca.crt" \
  "$SEED/ssh_host_ed25519_key.pub" "$SEED/ssh_host_ed25519_key-cert.pub"

cat <<EOF

provisioning complete for ${HOST}:
  seed:     ${SEED}
  sops:     ${SOPS_YAML}, ${BOOTSTRAP_YAML} (rewritten — commit before deploy)

next:
  1. git diff .sops.yaml modules/secrets/sops/bootstrap.yaml
  2. git add  .sops.yaml modules/secrets/sops/bootstrap.yaml modules/hosts/${HOST}/
  3. git commit -m "Provision host ${HOST}"
  4. scripts/deploy.sh <host-ip> ${HOST}
EOF
