{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.home.agent.asr-tts;
in
{
  options.features.home.agent.asr-tts = {
    enable = lib.mkEnableOption "local ASR/TTS voice agent packages";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Inference & Audio Tools
      piper-tts
      whisper-cpp
      wyoming-openwakeword
      espeak-ng
      
      # Audio backend support
      portaudio
      alsa-lib

      # Python environment for custom scripts
      (lib.hiPrio (python3.withPackages (
        ps: with ps; [
          pyaudio
          sounddevice
          numpy
          requests
          openai # For LiteLLM/Ollama compatible API calls
          wyoming # Wyoming protocol support
        ]
      )))
    ];
  };
}
