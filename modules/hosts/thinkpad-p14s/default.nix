{ den, inputs, ... }:
{
  den.hosts.x86_64-linux.thinkpad-p14s.users.eric = { };

  den.aspects.thinkpad-p14s = {
    includes = with den.aspects; [
      profile-wsl
    ];

    nixos =
      { ... }:
      {
        imports = [ inputs.nixos-wsl.nixosModules.default ];
        wsl.enable = true;
      };
  };
}
