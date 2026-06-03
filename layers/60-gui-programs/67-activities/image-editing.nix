{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-60.gui.activities.image-editing;
in
{
  options.layers.layer-60.gui.activities.image-editing.enable = lib.mkEnableOption "Image Editing";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gimp2 # Raster graphics editor.
      inkscape # Vector graphics editor.
      krita # Digital painting and raster graphics editor.
      digikam # Digital photo management application.
      libresprite # Sprite editor.
      pixelorama # sprite editor.
      pixeluvo # photo and image editor.
      pixieditor # Universal editor for all your 2D needs.
    ];
  };
}
