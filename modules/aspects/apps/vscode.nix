{ den, ... }:
{
  den.aspects.vscode.homeManager =
    { pkgs, ... }:
    {
      programs.vscode.enable = true;
    };
}
