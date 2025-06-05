{ config, lib, ... }: {
  config = lib.mkMerge [
    (lib.mkIf (config.home-manager.users |> builtins.hasAttr "esinger") {
      users.users."esinger" = {
        hashedPasswordFile = config.sops.secrets."passwords/esinger".path;
        description = "Eric Singer";
        extraGroups = [
          "video"
          "audio"
          "networkmanager"
          "tss"
          "builders"
        ];
      };
      sops.secrets."passwords/esinger".neededForUsers = true;
    })
  ];
}
