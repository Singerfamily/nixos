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
          ];

          sessionVariables = {
            DOTNET_PATH = "${sdk}/bin/dotnet";
            DOTNET_ROOT = "${sdk}/share/dotnet";
            # Point .NET to system certificate store
            SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
            DOTNET_SSL_DIRS = "${config.home.homeDirectory}/.aspnet/dev-certs/https:${pkgs.cacert}/etc/ssl/certs";
          };

          activation.dotnetDevCerts = config.lib.dag.entryAfter [ "writeBoundary" ] ''
            # Generate .NET development certificates if they don't exist
            CERT_DIR="${config.home.homeDirectory}/.aspnet/dev-certs/https"
            
            if [ ! -d "$CERT_DIR" ] || [ ! -f "$CERT_DIR/aspnetcore-localhost.pfx" ]; then
              $DRY_RUN_CMD mkdir -p "$CERT_DIR"
              
              # Generate certificates (skip clean as it requires system access)
              $DRY_RUN_CMD ${sdk}/bin/dotnet dev-certs https --export-path "$CERT_DIR/aspnetcore-localhost.pfx" --format Pfx --no-password || true
              $DRY_RUN_CMD ${sdk}/bin/dotnet dev-certs https --export-path "$CERT_DIR/aspnetcore-localhost.crt" --format Pem --no-password || true
              
              # Check if certificates were generated successfully
              if [ -f "$CERT_DIR/aspnetcore-localhost.crt" ]; then
                $DRY_RUN_CMD chmod 644 "$CERT_DIR/aspnetcore-localhost.crt"
                echo "Generated .NET development certificates in $CERT_DIR"
                echo ""
                echo "⚠️  To trust certificates system-wide, run after activation:"
                echo "  sudo cp $CERT_DIR/aspnetcore-localhost.crt /etc/ssl/certs/"
                echo "  sudo update-ca-certificates"
              else
                echo "Warning: Failed to generate .NET development certificates"
              fi
            fi
          '';
        };
    };
}
