{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.features.agent.asr-tts = {
    enable = lib.mkEnableOption "local ASR/TTS voice agent packages";
  };

  home = lib.mkIf config.features.agent.asr-tts.enable {
    home.packages = with pkgs; [
      piper-tts
      whisper-cpp
      wyoming-openwakeword
      espeak-ng
      portaudio
      alsa-lib

      (python3.withPackages (
        ps: with ps; [
          kokoro
          pyaudio
          sounddevice
          numpy
          requests
          openai
          wyoming
        ]
      ))
    ];
  };
}
