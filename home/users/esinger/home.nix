{pkgs, ...}: {
  home = {
    programs = {
      git = {
        enable = true;
        userName = "LeaderbotX400";
        userEmail = "eric@singerfamily.ca";
      };

      zsh.enable = true;
      zoxide.enable = true;
      fzf.enable = true;
    };

    package = with pkgs; [
      gh
      vscode
      microsoft-edge-dev
      zoxide
      fzf
    ];
  };
}