{ den, ... }:
{
  den.default.nixos = { lib, ... }: {
    security.sudo.extraConfig = lib.mkDefault ''
      Defaults env_keep += "EDITOR"
    '';
  };
}
