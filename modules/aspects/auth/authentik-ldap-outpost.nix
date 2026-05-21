_: {
  # Authentik LDAP outpost, run locally as an OCI container.
  #
  # The outpost connects *outbound* to Authentik over HTTPS and serves LDAP on
  # loopback only. SSSD therefore talks to ldap://localhost — LDAP never leaves
  # the host; only Authentik's authenticated API crosses the network. An
  # Authentik/outpost outage is handled the same as before: SSSD's credential
  # cache (see modules/aspects/auth/sssd.nix).
  #
  # We use the upstream image rather than nixpkgs' `authentik-outposts.ldap`
  # because nixpkgs lags upstream Authentik releases — the server needs the
  # outpost image to be within ~one minor version, and the packaged build is
  # often months behind.
  #
  # One shared Authentik outpost object; every host runs an instance with the
  # same token. The token is delivered at runtime by the OpenBao agent into
  # /run/authentik-ldap/env (see modules/aspects/services/openbao-agent.nix),
  # so it never enters the Nix store.
  #
  # TODO before deploy: pin `image` to the tag matching the Authentik server
  # version (e.g. ghcr.io/goauthentik/ldap:2026.2.0).
  den.aspects.authentik-ldap-outpost = _: {
    nixos = _: {
      virtualisation.oci-containers = {
        backend = "docker";
        containers.authentik-ldap = {
          image = "ghcr.io/goauthentik/ldap:2026.2";
          environment = {
            AUTHENTIK_HOST = "https://auth.singerfamily.ca";
            AUTHENTIK_INSECURE = "false";
          };
          # AUTHENTIK_TOKEN lives here, rendered by the OpenBao agent. docker
          # `--env-file` requires the file to exist at container start, so on
          # first boot this unit may fail until the agent renders the token —
          # the agent's template `command` then `try-restart`s the container,
          # and the oci-containers unit's default Restart=on-failure handles
          # the gap. Steady-state restarts on token rotation only.
          environmentFiles = [ "/run/authentik-ldap/env" ];
          # Loopback only — the LDAP service is never exposed off-host.
          ports = [
            "127.0.0.1:3389:3389"
            "127.0.0.1:6636:6636"
          ];
        };
      };

      # Needs the OpenBao-rendered token env-file before it can start.
      # `wants`, not `requires`: the agent's template `command` try-restarts
      # the container once the token lands.
      systemd.services.docker-authentik-ldap = {
        after = [ "vault-agent-openbao.service" ];
        wants = [ "vault-agent-openbao.service" ];
      };
    };
  };
}
