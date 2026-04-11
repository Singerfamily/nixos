{ den, ... }:
{
  den.aspects.dev-dotnet = {
    includes = [ den.aspects.dev-common];
    homeManager =
      { pkgs, lib, config, ... }:
      let
        dotnet = pkgs.dotnet-sdk_10;
        aspireCli = pkgs.stdenvNoCC.mkDerivation {
          pname = "aspire";
          version = "13.1.2";
          src = pkgs.fetchurl {
            url = "https://ci.dot.net/public/aspire/13.1.2-preview.1.26125.13/aspire-cli-linux-x64-13.1.2.tar.gz";
            hash = "sha256-cWCaQcZQqxYeSNpuHjiXD1ezLHCsJtOIlVIu5DRqNik=";
          };
          nativeBuildInputs = [ pkgs.makeWrapper ];
          sourceRoot = ".";
          unpackCmd = "tar -xzf $curSrc";
          installPhase = ''
            runHook preInstall
            install -Dm755 aspire $out/lib/aspire/aspire
            makeWrapper $out/lib/aspire/aspire $out/bin/aspire \
              --set DOTNET_SYSTEM_GLOBALIZATION_INVARIANT 1
            runHook postInstall
          '';
        };
      in
      {
        home.packages = [
          dotnet
          pkgs.dotnet-ef
          pkgs.nss.tools
          aspireCli
        ];
        home.sessionVariables = {
          DOTNET_ROOT = "${dotnet}";
          DOTNET_PATH = "${dotnet}/bin/dotnet";
          SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
          DOTNET_SSL_DIRS = "${config.home.homeDirectory}/.aspnet/dev-certs/https:/etc/ssl/certs";
        };

        # Generate and register ASP.NET Core HTTPS dev certificate into NSS DB
        home.activation.dotnetDevCerts = config.lib.dag.entryAfter [ "writeBoundary" ] ''
          CERT_DIR="${config.home.homeDirectory}/.aspnet/dev-certs/https"
          CERT_PFX="$CERT_DIR/aspnetcore-localhost.pfx"
          CERT_CRT="$CERT_DIR/aspnetcore-localhost.crt"
          CERTUTIL="${pkgs.nss.tools}/bin/certutil"
          CERT_NAME="ASP.NET Core HTTPS Development Certificate"
          NSS_DB="$HOME/.pki/nssdb"

          $DRY_RUN_CMD mkdir -p "$CERT_DIR"

          if [ ! -f "$CERT_PFX" ] || [ ! -f "$CERT_CRT" ]; then
            $DRY_RUN_CMD ${dotnet}/bin/dotnet dev-certs https --export-path "$CERT_PFX" --format Pfx --no-password || true
            $DRY_RUN_CMD ${dotnet}/bin/dotnet dev-certs https --export-path "$CERT_CRT" --format Pem --no-password || true
          fi

          if [ -f "$CERT_CRT" ]; then
            $DRY_RUN_CMD chmod 644 "$CERT_CRT"

            $DRY_RUN_CMD mkdir -p "$NSS_DB"
            if [ ! -f "$NSS_DB/key4.db" ]; then
              $DRY_RUN_CMD "$CERTUTIL" -d "sql:$NSS_DB" -N --empty-password
            fi

            $DRY_RUN_CMD "$CERTUTIL" -d "sql:$NSS_DB" -D -n "$CERT_NAME" || true
            $DRY_RUN_CMD "$CERTUTIL" -d "sql:$NSS_DB" -A -t "P,," -n "$CERT_NAME" -i "$CERT_CRT"
          fi
        '';
      };
  };
}
