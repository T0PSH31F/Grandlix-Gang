{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-60.gui.documents.feh;
in
{
  options.layers.layer-60.gui.documents.feh = {
    enable = lib.mkEnableOption "Feh lightweight image viewer";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ feh ];
  };
}
