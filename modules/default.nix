{libx, ...}: {
  imports = (libx.autoImport ./nixos) ++ (libx.autoImport ./home-manager);
}