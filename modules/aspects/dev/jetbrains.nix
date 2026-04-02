{ den, ... }:
{
  # JetBrains IDEs - include the ones you need per-user
  den.aspects.jetbrains-dotnet = {
    includes = [ den.aspects.dev-dotnet ];
    homeManager = { pkgs, ... }: { home.packages = [ pkgs.jetbrains.rider ]; };
  };
  den.aspects.jetbrains-rust = {
    includes = [ den.aspects.dev-rust ];
    homeManager = { pkgs, ... }: { home.packages = [ pkgs.jetbrains.rust-rover ]; };
  };
  den.aspects.jetbrains-python = {
    includes = [ den.aspects.dev-python ];
    homeManager = { pkgs, ... }: { home.packages = [ pkgs.jetbrains.pycharm-professional ]; };
  };
  den.aspects.jetbrains-java = {
    includes = [ den.aspects.dev-java ];
    homeManager = { pkgs, ... }: { home.packages = [ pkgs.jetbrains.idea-ultimate ]; };
  };
  den.aspects.jetbrains-go = {
    includes = [ den.aspects.dev-go ];
    homeManager = { pkgs, ... }: { home.packages = [ pkgs.jetbrains.goland ]; };
  };
  den.aspects.jetbrains-js = {
    includes = [ den.aspects.dev-js ];
    homeManager = { pkgs, ... }: { home.packages = [ pkgs.jetbrains.webstorm ]; };
  };
  den.aspects.jetbrains-c = {
    includes = [ den.aspects.dev-c ];
    homeManager = { pkgs, ... }: { home.packages = [ pkgs.jetbrains.clion ]; };
  };
  den.aspects.jetbrains-datagrip.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.jetbrains.datagrip ];
    };
}
