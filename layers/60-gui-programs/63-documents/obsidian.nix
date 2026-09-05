# Obsidian Note-Taking Client Module
{
  config,
  lib,
  pkgs,
  osConfig ? config,
  ...
}:
let
{
  options.layers.layer-60.gui.obsidian = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Obsidian note-taking tool";
    };
  };

  home =
    let
      cfg = config.layers.layer-60.gui.obsidian;
    in
    lib.mkIf cfg.enable {
    home.packages = [ pkgs.obsidian ];
  };
}
