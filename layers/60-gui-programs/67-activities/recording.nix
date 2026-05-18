{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-60.gui.activities.recording;
in
{
  options.layers.layer-60.gui.activities.recording.enable = lib.mkEnableOption "Recording";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      obs-studio
      tenv
      wf-recorder
    ];
  };
}
