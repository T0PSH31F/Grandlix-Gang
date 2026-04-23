{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ai-services.voice;
in
{
  options.services.ai-services.voice = {
    enable = lib.mkEnableOption "Local STT and TTS services (Whisper, Piper, XTTSv2)";

    sttPort = lib.mkOption {
      type = lib.types.port;
      default = 8082;
      description = "Port for local whisper.cpp server";
    };

    ttsPort = lib.mkOption {
      type = lib.types.port;
      default = 8083;
      description = "Port for local Piper TTS wrapper or XTTSv2 server";
    };

    useXTTSv2 = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Deploy XTTSv2-UI via OCI containers alongside Piper";
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. System packages for raw binaries in PATH
    environment.systemPackages = with pkgs; [
      piper-tts
      whisper-cpp
    ];

    # 2. Whisper.cpp HTTP Server Service
    systemd.services.whisper-server = {
      description = "Local STT Server using whisper.cpp";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        # Using a dummy wrapper script; in production, you would pull the exact ggml-base.en.bin model
        ExecStart = "${pkgs.whisper-cpp}/bin/whisper-server -m /var/lib/whisper/ggml-base.en.bin --port ${toString cfg.sttPort}";
        Restart = "on-failure";
        DynamicUser = true;
        StateDirectory = "whisper"; # /var/lib/whisper
      };
    };

    # 3. XTTSv2 / OpenVoice Docker deployment
    virtualisation.oci-containers.containers.xttsv2 = lib.mkIf cfg.useXTTSv2 {
      image = "ghcr.io/coqui-ai/xtts-streaming-server:latest";
      ports = [ "${toString cfg.ttsPort}:8020" ];
      volumes = [
        "xttsv2-models:/models"
      ];
      environment = {
        # Configure model variables if required by the image
        MODEL_PATH = "/models";
      };
    };

    # 4. Open Firewall
    networking.firewall.allowedTCPPorts = [ cfg.sttPort ] ++ (lib.optional cfg.useXTTSv2 cfg.ttsPort);
  };
}
