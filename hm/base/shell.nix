# Baseline shell-only home-manager config for every LDAP-provisioned user.
# Applied on ALL managed hosts, graphical or headless. Keep this strictly
# non-graphical — servers and WSL get only this layer.
_:
{
  programs.zsh.enable = true;
  programs.git.enable = true;
}
