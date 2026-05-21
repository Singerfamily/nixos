_:
{
  den.default =
    let
      stateVersion = "26.05";
    in
    {
      nixos.system.stateVersion = stateVersion;
      homeManager.home.stateVersion = stateVersion;
    };
}
