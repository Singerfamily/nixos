{ den, ... }:
{
  # Impermanence support — btrfs root rollback on boot.
  # Disabled / commented out. Requires impermanence flake input and
  # careful per-host configuration of persistence paths.
  #
  # To enable:
  # 1. Add impermanence input to flake-file.inputs in dendritic.nix
  # 2. Import inputs.impermanence.nixosModules.impermanence in the host
  # 3. Configure boot.initrd.postResumeCommands for btrfs subvolume rollback
  # 4. Set home.persistence paths for each user
  #
  # See nixos-old/modules/home/impermanence for the original implementation.
  den.aspects.impermanence = { };
}
