{ config, lib, pkgs, ... }:
let cfg = config.layers.layer-60.gui.activities.music-production;
in {
  options.layers.layer-60.gui.activities.music-production.enable = lib.mkEnableOption "Music Production";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ ardour audacity musescore LMMS reaper bitwig-studio ];
  };
}
