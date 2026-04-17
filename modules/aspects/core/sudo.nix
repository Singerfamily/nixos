_:
{
  den.default.nixos =
    _:
    {
      security.sudo.extraConfig = ''
        Defaults env_keep += "EDITOR"
      '';
    };
}
