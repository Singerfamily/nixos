{ den, ... }:
{
  den.aspects.dev-dotnet = {
    includes = [ den.aspects.dev ];
    homeManager =
      { pkgs, lib, ... }:
      let
        dotnet = pkgs.dotnet-sdk_10;
      in
      {
        home.packages = [
          dotnet
          pkgs.dotnet-ef
        ];
        home.sessionVariables = {
          DOTNET_ROOT = "${dotnet}";
        };
      };
  };
}
