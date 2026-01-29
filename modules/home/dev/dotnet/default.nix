# INFO: Dotnet Home-manager module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.dev.dotnet = {

    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config =
    let
      inherit (config.snowfall.dev.dotnet)
        enable
        ;
    in
    mkIf enable {
      home =
        let
          sdk = (with pkgs.dotnetCorePackages; combinePackages [ sdk_10_0_1xx-bin ]);
        in
        {
          packages = with pkgs; [
            sdk
            dotnet-ef
            nss.tools
          ];

          sessionVariables = {
            DOTNET_PATH = "${sdk}/bin/dotnet";
            DOTNET_ROOT = "${sdk}/share/dotnet";
            # Point .NET to system certificate store
            SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
            DOTNET_SSL_DIRS = "${config.home.homeDirectory}/.aspnet/dev-certs/https:${pkgs.cacert}/etc/ssl/certs";
          };

          activation.dotnetDevCerts = config.lib.dag.entryAfter [ "writeBoundary" ] ''
            CERT_DIR="${config.home.homeDirectory}/.aspnet/dev-certs/https"
            CERT_PFX="$CERT_DIR/aspnetcore-localhost.pfx"
            CERT_CRT="$CERT_DIR/aspnetcore-localhost.crt"
            CERTUTIL="${pkgs.nss.tools}/bin/certutil"
            CERT_NAME="ASP.NET Core HTTPS Development Certificate"
            NSS_DB="$HOME/.pki/nssdb"

            $DRY_RUN_CMD mkdir -p "$CERT_DIR"

            if [ ! -f "$CERT_PFX" ] || [ ! -f "$CERT_CRT" ]; then
              $DRY_RUN_CMD ${sdk}/bin/dotnet dev-certs https --export-path "$CERT_PFX" --format Pfx --no-password || true
              $DRY_RUN_CMD ${sdk}/bin/dotnet dev-certs https --export-path "$CERT_CRT" --format Pem --no-password || true
            fi

            if [ -f "$CERT_CRT" ]; then
              $DRY_RUN_CMD chmod 644 "$CERT_CRT"

              $DRY_RUN_CMD mkdir -p "$NSS_DB"
              if [ ! -f "$NSS_DB/key4.db" ]; then
                $DRY_RUN_CMD "$CERTUTIL" -d "sql:$NSS_DB" -N --empty-password
              fi

              $DRY_RUN_CMD "$CERTUTIL" -d "sql:$NSS_DB" -D -n "$CERT_NAME" || true
              $DRY_RUN_CMD "$CERTUTIL" -d "sql:$NSS_DB" -A -t "P,," -n "$CERT_NAME" -i "$CERT_CRT"

              echo "Registered ASP.NET Core HTTPS development certificate in $NSS_DB"
            else
              echo "Warning: Failed to generate .NET development certificates"
            fi
          '';
        };
    };
}
