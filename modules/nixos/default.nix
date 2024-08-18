{libx, lib, ...}: {
  imports = 
    (libx.autoImport ./core) ++
    (libx.autoImport ./apps) ++ 
    (libx.autoImport ./desktop) ++
    (libx.autoImport ./hardware) ++
    (libx.autoImport ./services);
  
  desktop.plasma.enable = lib.mkDefault true;
}