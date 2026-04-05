{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.snowfall.dev-tools;

  dotnet = with pkgs.dotnetCorePackages; combinePackages [
    sdk_10_0
    sdk_9_0
    aspnetcore_10_0
    aspnetcore_9_0
  ];
in

{
  options.snowfall.dev-tools = {
    enable = mkEnableOption "Full-stack developer tooling (languages, databases, cloud CLIs, etc.)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # --- Version Control & Core Tools ---
      gitFull               # includes gitk (upgrades git from ai-tools)
      gitkraken             # Git GUI
      lazygit
      fzf
      tmux

      # --- .NET ---
      dotnet
      icu                   # required by vsdbg (VS Code .NET debugger)

      # --- Node.js / Web ---
      nodejs_22
      nodePackages.npm
      nodePackages.pnpm
      yarn
      nodePackages.typescript
      deno
      bun

      # --- Python / AI & ML ---
      python313
      python313Packages.pip
      python313Packages.virtualenv
      python313Packages.numpy
      python313Packages.pandas
      python313Packages.scipy
      python313Packages.scikit-learn
      python313Packages.matplotlib
      python313Packages.jupyter
      python313Packages.ipython
      python313Packages.requests
      python313Packages.pyyaml

      # --- Containers & Infrastructure ---
      kubectl
      kubernetes-helm
      terraform
      pulumi

      # --- Databases ---
      postgresql_18
      redis

      # --- API & Networking ---
      postman
      openssl

      # --- Go ---
      go
      gopls                 # Go LSP
      golangci-lint         # Go linter

      # --- Build Tools ---
      gnumake
      cmake
      gcc
      pkg-config

      # --- Editors & LSP ---
      neovim
      nodePackages.vscode-langservers-extracted  # HTML/CSS/JSON LSP
      nodePackages.yaml-language-server
      marksman              # Markdown LSP

      # --- Linting & Formatting ---
      nixpkgs-fmt
      black                 # Python formatter

      # --- Cloud CLIs ---
      awscli2
      # azure-cli              # currently broken on unstable with Python 3.13
      google-cloud-sdk
    ];

    # SSH config for GitHub over port 443 (firewalls/proxies)
    programs.ssh.extraConfig = ''
      Host github.com
        Hostname ssh.github.com
        Port 443
    '';

    # Global git config — enforce LF, set identity
    programs.git = {
      enable = true;
      config = {
        user = {
          name = "Clint Singer";
          email = "clint.singer@gomodular.ca";
        };
        core = {
          autocrlf = "input";
          eol = "lf";
        };
        init.defaultBranch = "main";
        pull.rebase = false;
        fetch.prune = true;
      };
    };

    # .NET environment variables
    environment.variables = {
      DOTNET_CLI_TELEMETRY_OPTOUT = "1";
      DOTNET_ROOT = "${dotnet}/share/dotnet";
      DOTNET_MSBUILD_SDK_RESOLVER_CLI_DIR = "${dotnet}";
      # vsdbg needs ICU; also preserve PipeWire JACK lib path
      LD_LIBRARY_PATH = lib.mkForce "${pkgs.icu}/lib:${pkgs.pipewire.jack}/lib";
    };

    # Add dotnet global tools to PATH
    environment.profiles = [ "$HOME/.dotnet/tools" ];

    # Allow VS Code debugger to attach to running .NET processes
    boot.kernel.sysctl."kernel.yama.ptrace_scope" = 0;
  };
}
