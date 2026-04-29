# Template: Minimal, well-structured aspect
#
# This template shows the anatomy of a good aspect:
# - Clear structure (includes, nixos, homeManager, provides)
# - Single concern (one domain/feature)
# - Documented purpose
# - Parameterized for reuse via Nix options
#
# Copy this template when creating a new aspect:
# $ scripts/new-aspect.sh <domain> <name>
# or:
# $ cp templates/ASPECT_TEMPLATE.nix modules/aspects/<domain>/<name>.nix
#
# Then:
# 1. Update `den.aspects.my-feature` to match the filename.
# 2. Reference it from a host (`den.aspects.<host>.includes`) or a user
#    (`den.aspects.<user>.includes`) — every aspect needs a consumer.
# 3. Test: nix flake check --no-build

{ den, ... }:
{
  # REQUIRED: The unique name for this aspect (must match filename).
  # Referenced as `den.aspects.my-feature` in includes lists.
  den.aspects.my-feature = {
    # What other aspects does this depend on?
    # Example: includes = with den.aspects; [ sops ssh git ];
    # Cycles are not allowed.
    includes = with den.aspects; [
      # sops    # if the aspect uses secrets
      # ssh     # if the aspect implies SSH server config
    ];

    # (Optional) USER metadata — only when the aspect defines a service account.
    # user = {
    #   name = "myservice";
    #   description = "My Service Account";
    # };

    # (Optional) NIXOS-LEVEL configuration.
    # Use for: system packages, services, boot, hardware, sops secrets.
    # Syntax: nixos = { config, lib, pkgs, ... }: { ... }
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        # Example: install a system package
        # environment.systemPackages = with pkgs; [ package ];

        # Example: enable a service
        # services.my-service.enable = true;

        # Example: set an option
        # programs.git.enable = true;

        # ── Options-based aspects ────────────────────────────────────
        # When the aspect encodes reusable structure with per-instance
        # values (e.g. a driver list, bus IDs, an org name), declare
        # options.den.<aspect>.* and let consuming hosts set them.
        #
        # Pattern:
        #
        #   options.den.myFeature = {
        #     enable = lib.mkEnableOption "my reusable feature";
        #     target = lib.mkOption {
        #       type = lib.types.str;
        #       description = "Per-instance target value.";
        #     };
        #   };
        #   config = lib.mkIf config.den.myFeature.enable {
        #     services.my-feature = {
        #       enable = true;
        #       target = config.den.myFeature.target;
        #     };
        #   };
        #
        # Existing examples in tree:
        #   services/user/printing.nix      — den.printing.{enable,drivers}
        #   hardware/gpu.nix (gpu-nvidia-prime) — den.gpuPrime.{intelBusId,nvidiaBusId}
        #   apps/azure-devops.nix           — den.azureDevOps.{organization,project}
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
