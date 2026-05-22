{ inputs, ... }:
{
  flake-file.inputs.determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

  # Determinate manages the Nix installation itself, so keep it off the WSL
  # host where nixos-wsl already owns Nix. Attached via the desktop and
  # server profiles rather than den.default.
  den.aspects.determinate.nixos = _: {
    imports = [ inputs.determinate.nixosModules.default ];
  };
}
