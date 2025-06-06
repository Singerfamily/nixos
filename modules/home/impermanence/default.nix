{
  inputs,
  lib,
  config,
  ...
}:

with builtins;
with lib;

let
  users = attrNames (config.home-manager.users or { });
in
{
  imports = with inputs; [
    impermanence.nixosModules.home-manager.impermanence
  ];

  options.snowfall.impermanence = {
    enable = mkOption {
      type = with types; bool;
      default = false;
      description = "Whether to apply common configurations to Impermanence";
    };

    allowOther = mkOption {
      type = with types; bool;
      default = true;
      description = "Whether to allow other users to access the persistent directories";
    };
  };

  # config = mkIf config.snowfall.impermanence.enable (
  #   lib.mkMerge (
  #     {
  #       boot.initrd.postResumeCommands = lib.mkAfter ''
  #         mkdir /btrfs_tmp
  #         mount /dev/root_vg/root /btrfs_tmp
  #         if [[ -e /btrfs_tmp/root ]]; then
  #             mkdir -p /btrfs_tmp/old_roots
  #             timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
  #             mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
  #         fi

  #         delete_subvolume_recursively() {
  #             IFS=$'\n'
  #             for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
  #                 delete_subvolume_recursively "/btrfs_tmp/$i"
  #             done
  #             btrfs subvolume delete "$1"
  #         }

  #         for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
  #             delete_subvolume_recursively "$i"
  #         done

  #         btrfs subvolume create /btrfs_tmp/root
  #         umount /btrfs_tmp
  #       '';
  #     }
  #     ++ map (username: {
  #       home.persistence."${lib.snowfall.persist}/home/${username}" = {
  #         directories =
  #           let
  #             xdgDirs =
  #               attrValues config.home-manager.users.${username}.xdg.userDirs
  #               |> filter (value: isString value)
  #               |> map (dir: replaceStrings [ "/home/${username}/" ] [ "" ] dir);
  #           in
  #           xdgDirs
  #           ++ [
  #             ".android"
  #             ".cache"
  #             ".cargo"
  #             ".docker"
  #             ".gnupg"
  #             ".icons"
  #             ".java"
  #             ".librewolf"
  #             ".local"
  #             ".mozilla"
  #             ".rustup"
  #             ".ssh"
  #             ".var"
  #             "Camera"
  #             "Files"
  #             "Library"
  #             "projects"
  #             "Documents"
  #             "Downloads"
  #             "Music"
  #             "Pictures"
  #             "Videos"
  #           ];
  #         files = [ ".wallpaper" ];
  #         allowOther = true;
  #       };
  #     }) users
  #   )
  # );
}
