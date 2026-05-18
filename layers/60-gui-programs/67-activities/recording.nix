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
      chatterino7
      twitch-hls-client
      twitch-cli
      obs-cli
      wf-recorder
      ffmpeg
      kdenlive
      shotcut
    ];

    home-manager.users.t0psh31f = {
      programs.obs-studio = {
        enable = true;
        package = pkgs.obs-studio;
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          pixel-art
          waveform
          obs-websocket
          obs-vnc
          obs-vkcapture
          obs-vintage-filter
          obs-ndi
          obs-scene-switcher
          obs-transition-plugin
          obs-transform-plugin
          obs-browser-plugin
          obs-backgroundremoval
          obs-aitum-multistream
          obs-advanced-masks
          obs-3d-effect
          looking-glass-obs
          input-overlay
          droidcam-obs
        ];
      };
    };
  };
}
