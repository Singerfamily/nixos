{ den, inputs, ... }:
{
  den.hosts.x86_64-linux.thinkpad-p14s.users.esinger = { };

  den.aspects.thinkpad-p14s = {
    includes = with den.aspects; [
      profile-wsl
    ];

    nixos =
      { lib, ... }:
      {
        imports = [ inputs.nixos-wsl.nixosModules.default ];
        wsl.enable = true;
      };
  };
}
