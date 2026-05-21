# Baseline desktop home-manager config — Plasma workspace defaults shared by
# every LDAP-provisioned user on a GRAPHICAL managed host. Pulled into the
# portable closure only when the host has Plasma; never evaluated on headless
# hosts (plasma-manager is not imported there).
_:
{
  programs.plasma = {
    enable = true;
    overrideConfig = true;

    workspace = {
      clickItemTo = "select";
      colorScheme = "BreezeDark";
      tooltipDelay = 1;
    };

    session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";
  };
}
