{ lib, ... }:

with lib;
{
  den.schema.host = {
    options.iso = lib.mkOption {
      type = types.bool;
      description = "ISO image build";
      default = false;
    };
  };

  den.schema.user = {
    config.classes =  [ "homeManager" ];
  };
}
