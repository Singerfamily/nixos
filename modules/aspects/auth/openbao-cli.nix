_: {
  # Point the `bao` CLI at our OpenBao instance system-wide. Without this the
  # CLI defaults to https://127.0.0.1:8200 and `bao login -method=oidc` fails
  # with "connection refused". Scripts under scripts/ already default
  # BAO_ADDR to this value; this makes interactive use match.
  den.aspects.openbao-cli = {
    nixos = _: {
      environment.sessionVariables.BAO_ADDR = "https://secrets.singerfamily.ca";
    };
  };
}
