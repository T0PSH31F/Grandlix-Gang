{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-60.gui.activities.music-production;
in
{
  options.layers.layer-60.gui.activities.music-production.enable =
    lib.mkEnableOption "Music Production";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ardour # hard disk recording software
      audacity # audio editor
      musescore # music notation software
      lmms-full # DAW
      reaper # DAW
      reaper-sws-extension # SWS/S&M Extension for Reaper
      reaper-reapack-extension # ReaPack Extension for Reaper
      bitwig-studio # DAW
      synthesia # fun way to learn piano
      x42-plugins # Collection of LV2 plugins by Robin Gareus
      x42-gmsynth # GMSynth is a virtual synthesizer.
      x42-avldrums # A collection of high quality drum samples.
      guitarix # LV2 guitar amplifier and effects processor.
      guitarix-vst # VST3 plugins for guitarix.
      fluidsynth # Software synthesizer.
      bespokesynth # Modular software synthesizer.
      exefmsynth # VST plugins
      hydrogen # Drum Machine
      ams # Advanced Modular Synthesizer
      calf # Set of high quality open source audio plugins for musicians.
      qsynth # Fluidsynth GUI
    ];

    home-manager.users.${config.layers.meta.primaryUser}.services.fluidsynth.enable = true;
  };
}
