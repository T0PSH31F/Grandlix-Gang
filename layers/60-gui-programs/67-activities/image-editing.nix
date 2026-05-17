{ config, lib, pkgs, ... }:
let cfg = config.layers.layer-60.gui.activities.image-editing;
in {
  options.layers.layer-60.gui.activities.image-editing.enable = lib.mkEnableOption "Image Editing";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ gimp inkscape krita ];
  };
}
