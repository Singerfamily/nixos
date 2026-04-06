{ den, ... }:
{
  den.default.nixos = { lib, ... }: {
    security.sudo.extraConfig =  ''
      Defaults env_keep += "EDITOR"
    '';
  };
}
