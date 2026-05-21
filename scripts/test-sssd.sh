#!/usr/bin/env bash
#
# Manual SSSD / Authentik-LDAP smoke test. Run ON the managed host (nebula)
# as a user that can sudo — it needs to read the OpenBao-rendered bind creds
# in /etc/sssd/conf.d/ and to flush the SSSD cache.
#
#   sudo scripts/test-sssd.sh <username>
#
# Walks the auth chain layer by layer so a failure points at the broken rung:
#   1. outpost container is up + listening on loopback
#   2. LDAP bind as the service account works
#   3. the target user is VISIBLE to LDAP (Authentik search-group gating)
#   4. the user carries posixAccount + uidNumber (SSSD requires these)
#   5. NSS resolves the user (getent)
#   6. PAM accepts the user's password
#
# Step 6 uses `pamtester`, NOT `su`. `su <user>` invoked by root never
# prompts for a password (root may become anyone), so a root-run `su` test
# is a false positive — it proves nothing about the password. `pamtester`
# drives the real PAM auth stack (pam_unix -> pam_sss) and only succeeds if
# the password actually authenticates.
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "must run as root (sudo) — needs the bind creds in /etc/sssd/conf.d" >&2
  exit 1
fi

USER_TO_TEST=${1:-}
if [[ -z ${USER_TO_TEST} ]]; then
  echo "usage: sudo $0 <username>" >&2
  exit 1
fi

BIND_CONF=/etc/sssd/conf.d/01-ldap-bind.conf
LDAP_URI=ldap://localhost:3389
BASE_DN=dc=ldap,dc=goauthentik,dc=io

pass() { printf '  \033[32mPASS\033[0m  %s\n' "$1"; }
fail() {
  printf '  \033[31mFAIL\033[0m  %s\n' "$1"
  exit 1
}
step() { printf '\n\033[1m== %s\033[0m\n' "$1"; }

# ldapsearch isn't in the system profile — pull it on demand.
ldapsearch() { nix-shell -p openldap --run "ldapsearch $*"; }

# --- 1. outpost container ---------------------------------------------------
step "1. Authentik LDAP outpost container"
if docker ps --filter name=authentik-ldap --filter status=running --format '{{.Names}}' |
  grep -qx authentik-ldap; then
  pass "container authentik-ldap is running"
else
  fail "container authentik-ldap is not running (systemctl status docker-authentik-ldap)"
fi
if ss -tlnH 'sport = 3389' | grep -q 127.0.0.1; then
  pass "outpost listening on 127.0.0.1:3389"
else
  fail "nothing listening on 127.0.0.1:3389"
fi

# --- 2. bind creds ----------------------------------------------------------
step "2. LDAP service-account bind"
[[ -r ${BIND_CONF} ]] || fail "${BIND_CONF} missing — OpenBao agent has not rendered it"
BIND_DN=$(sed -n 's/^ldap_default_bind_dn = //p' "${BIND_CONF}")
BIND_PW=$(sed -n 's/^ldap_default_authtok = //p' "${BIND_CONF}")
[[ -n ${BIND_DN} && -n ${BIND_PW} ]] || fail "bind DN / password not found in ${BIND_CONF}"
echo "  bind DN: ${BIND_DN}"

PW_FILE=$(mktemp)
trap 'rm -f "${PW_FILE}"' EXIT
printf '%s' "${BIND_PW}" >"${PW_FILE}"

if ldapsearch "-x -LLL -H ${LDAP_URI} -D '${BIND_DN}' -y '${PW_FILE}' \
     -b '${BASE_DN}' -s base '(objectClass=*)' dn" >/dev/null 2>&1; then
  pass "bound to outpost as service account"
else
  fail "bind failed — check the ldap-service-account secret in OpenBao"
fi

# --- 3. user visibility -----------------------------------------------------
step "3. Target user visible over LDAP"
ENTRY=$(ldapsearch "-x -LLL -H ${LDAP_URI} -D '${BIND_DN}' -y '${PW_FILE}' \
  -b '${BASE_DN}' -s sub '(cn=${USER_TO_TEST})' \
  dn cn uid uidNumber gidNumber homeDirectory loginShell objectClass" 2>/dev/null || true)
if [[ -z ${ENTRY} ]]; then
  fail "user '${USER_TO_TEST}' not visible to LDAP — add them to the LDAP provider's Search group in Authentik"
fi
pass "user '${USER_TO_TEST}' found in directory"
echo "${ENTRY}" | sed 's/^/    /'

# --- 4. posix attributes ----------------------------------------------------
step "4. POSIX account attributes"
if grep -qi '^objectClass: posixAccount' <<<"${ENTRY}"; then
  pass "objectClass posixAccount present"
else
  fail "no posixAccount objectClass — SSSD will ignore this user (check provider property mappings)"
fi
UIDNUM=$(sed -n 's/^uidNumber: //p' <<<"${ENTRY}")
if [[ -n ${UIDNUM} && ${UIDNUM} -gt 0 ]]; then
  pass "uidNumber = ${UIDNUM}"
else
  fail "missing/zero uidNumber — set the provider's UID start number in Authentik"
fi

# --- 5. NSS resolution ------------------------------------------------------
step "5. NSS resolution via SSSD"
sss_cache -E 2>/dev/null || true
if getent passwd "${USER_TO_TEST}"; then
  pass "getent passwd ${USER_TO_TEST} resolves"
else
  fail "getent did not resolve — see journalctl -u sssd"
fi

# --- 6. PAM auth ------------------------------------------------------------
step "6. PAM authentication (real auth stack via pamtester)"
echo "  driving the 'login' PAM service — enter ${USER_TO_TEST}'s Authentik"
echo "  password when prompted (input is hidden)."
echo
if nix-shell -p pamtester --run "pamtester login '${USER_TO_TEST}' authenticate"; then
  pass "PAM accepted the password — pam_sss bound to Authentik successfully"
  echo
  printf '\033[1;32mALL CHECKS PASSED\033[0m — %s can authenticate on this host.\n' "${USER_TO_TEST}"
else
  fail "PAM rejected the password — see: journalctl -u sssd ; docker logs authentik-ldap"
fi
