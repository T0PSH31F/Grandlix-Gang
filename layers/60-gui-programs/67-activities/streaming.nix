{ config, lib, pkgs, ... }:
let cfg = config.layers.layer-60.gui.activities.streaming;
in {
  options.layers.layer-60.gui.activities.streaming.enable = lib.mkEnableOption "Streaming";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ obs-studio ];
  };
}
