# flake-parts/system/clan-lib.nix
{ config, lib, ... }:
{
  options.machine.tags = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Tags for tag-based configuration";
  };

  options.machine.lib = {
    hasTag = lib.mkOption {
      type = lib.types.functionTo lib.types.bool;
      description = "Helper to check if a machine has a specific tag";
    };

    hasTags = lib.mkOption {
      type = lib.types.functionTo lib.types.bool;
      description = "Helper to check if a machine has any of the specific tags";
    };
  };

  config.machine.lib = {
    hasTag = tag: lib.elem tag config.machine.tags;
    hasTags = tags: lib.any (tag: lib.elem tag config.machine.tags) tags;
  };
}
