{ inputs, ... }:
{
  # Overlay that provides disko and disko-doc packages from the disko flake input
  flake.overlays.disko = _final: prev: {
    inherit (inputs.disko.packages.${prev.system})
      disko
      disko-doc
      ;
  };
}
