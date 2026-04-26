# Template: Minimal, well-structured aspect
#
# This template shows the anatomy of a good aspect:
# - Clear structure (includes, nixos, homeManager, provides)
# - Single concern (one domain/feature)
# - Documented purpose
# - Parameterized for reuse
#
# Copy this template when creating a new aspect:
# $ cp templates/ASPECT_TEMPLATE.nix modules/aspects/my-domain/my-feature.nix
#
# Then:
# 1. Update `den.aspects.my-feature` name
# 2. Add to feature_includes if it's user-level (homeManager)
# 3. Add to host_includes if it's system-level (nixos)
# 4. Test: nix eval .#nixosConfigurations.<host>.config.system.stateVersion

{ den, ... }:
{
  # REQUIRED: The unique name for this aspect (must match filename)
  # Used as: den.aspects.my-feature in includes lists
  den.aspects.my-feature = {
    # LIST: What other aspects does this depend on?
    # Example: includes = with den.aspects; [ sops ssh git ];
    # Circular includes are NOT allowed (flakes prevent them)
    includes = with den.aspects; [
      # den.provides.primary-user,  # if you configure the primary user
      # sops,                        # if you need secrets
    ];

    # (Optional) USER metadata: Only set if you want this aspect to define a new user
    # Generally NOT needed unless you're adding a service account
    # user = {
    #   name = "myservice";
    #   description = "My Service Account";
    # };

    # (Optional) NIXOS-LEVEL configuration
    # Use this for: system packages, services, boot, hardware, sops secrets
    # This runs at the NixOS evaluation level
    # Syntax: nixos = { config, lib, pkgs, ... }: { ... }
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        # Example: Install a system package
        # environment.systemPackages = with pkgs; [ package ];

        # Example: Enable a service
        # services.my-service.enable = true;

        # Example: Set an option
        # programs.git.enable = true;
      };

    # (Optional) HOME-MANAGER configuration (applied to all users on all hosts)
    # Use this for: user shell aliases, dot files, per-user tools
    # This runs at the Home Manager evaluation level (after nixos)
    # Syntax: homeManager = { config, lib, pkgs, ... }: { ... }
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        # Example: Install a user package
        # home.packages = with pkgs; [ neovim ];

        # Example: Configure a program
        # programs.git.settings = {
        #   user.name = "My Name";
        #   user.email = "me@example.com";
        # };

        # Example: Set environment variable
        # home.sessionVariables = {
        #   EDITOR = "nvim";
        # };
      };

    # (Optional) HOST-SPECIFIC user configuration via provides
    # Use this for: host-specific packages, Plasma config, per-host overrides
    # Syntax: provides.<hostname>.homeManager = { config, pkgs, ... }: { ... }
    #
    # Example: Different packages on different hosts
    # "provides.event-horizon.homeManager" — packages only on event-horizon
    # "provides.clint-pc.homeManager" — different config on clint-pc
    provides = {
      # event-horizon.homeManager = { pkgs, ... }: {
      #   home.packages = with pkgs; [ intel-gpu-tools ];
      # };
      #
      # clint-pc.homeManager = { pkgs, ... }: {
      #   home.packages = with pkgs; [ nvidia-utils ];
      # };
    };

    # (Optional) HOST-LEVEL configuration via provides
    # Use this for: hardware config, boot options, host-specific services
    # Syntax: provides.<hostname>.nixos = { config, lib, pkgs, ... }: { ... }
    #
    # provides = {
    #   event-horizon.nixos = { lib, ... }: {
    #     # Only on event-horizon
    #     hardware.enableRedistributableFirmware = true;
    #   };
    # };
  };
}
