{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.voice;
in
{
  options.services.ai-services.voice = {
    enable = lib.mkEnableOption "Local STT and TTS services (Whisper, Piper, XTTSv2)";

    sttPort = lib.mkOption {
      type = lib.types.port;
      default = 8089;
      description = "Port for local whisper.cpp server";
    };

    ttsPort = lib.mkOption {
      type = lib.types.port;
      default = 8083;
      description = "Port for local Piper TTS wrapper or XTTSv2 server";
    };

    useXTTSv2 = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Deploy XTTSv2-UI via OCI containers alongside Piper";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      piper-tts
      whisper-cpp
    ];

    # Whisper.cpp HTTP Server
    systemd.services.whisper-server = {
      description = "Local STT Server using whisper.cpp";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.whisper-cpp}/bin/whisper-server -m /var/lib/whisper/ggml-base.en.bin --port ${toString cfg.sttPort}";
        Restart = "on-failure";
        DynamicUser = true;
        StateDirectory = "whisper";
      };
      preStart = ''
        mkdir -p /var/lib/whisper
        if [ ! -f /var/lib/whisper/ggml-base.en.bin ]; then
          echo "Downloading Whisper model (ggml-base.en.bin)..."
          if ! ${pkgs.curl}/bin/curl -L -f -o /var/lib/whisper/ggml-base.en.bin "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin"; then
            echo "Failed to download ggml-base.en.bin" >&2
            rm -f /var/lib/whisper/ggml-base.en.bin
            exit 1
          fi
        fi
        if [ ! -f /var/lib/whisper/ggml-base.en.bin ] || [ ! -s /var/lib/whisper/ggml-base.en.bin ]; then
          echo "Failed to verify ggml-base.en.bin (missing or empty)" >&2
          rm -f /var/lib/whisper/ggml-base.en.bin
          exit 1
        fi
      '';
    };

    virtualisation.oci-containers.containers.xttsv2 = lib.mkIf cfg.useXTTSv2 {
      image = "ghcr.io/coqui-ai/xtts-streaming-server:latest";
      ports = [ "${toString cfg.ttsPort}:8020" ];
      volumes = [ "xttsv2-models:/models" ];
      environment = { MODEL_PATH = "/models"; };
    };

    networking.firewall.allowedTCPPorts = [ cfg.sttPort ] ++ (lib.optional cfg.useXTTSv2 cfg.ttsPort);
  };
}