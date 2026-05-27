# Obsidian Note-Taking Client Module
{
  config,
  lib,
  pkgs,
  osConfig ? config,
  ...
}:
let
  cfg = osConfig.layers.layer-60.gui.obsidian;
  hasDesktopTag = builtins.elem "desktop" (osConfig.machine.tags or [ ]);
in
{
  options.layers.layer-60.gui.obsidian = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = hasDesktopTag;
      description = "Enable Obsidian note-taking tool";
    };
  };

  home = lib.mkIf cfg.enable {
    home.packages = [ pkgs.obsidian ];
  };
}
