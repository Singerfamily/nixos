{ libx, ... }:
{
  imports = (libx.autoImport ./zsh) ++ (libx.autoImport ./git);
}
