{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.localai;
in
{
  options.services.ai-services.localai = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable LocalAI service";
    };

    port = mkOption {
      type = types.int;
      default = 8081;
      description = "LocalAI port";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.local-ai = {
      image = "quay.io/go-skynet/local-ai:latest";
      ports = [ "${toString cfg.port}:8080" ];
      volumes = [
        "local-ai-models:/models"
      ];
      environment = {
        THREADS = "4";
        CONTEXT_SIZE = "512";
      };
    };

    virtualisation.podman.enable = true;
    virtualisation.oci-containers.backend = "podman";

    networking.firewall.allowedTCPPorts = [ cfg.port ];

    environment.persistence."/persist" =
      mkIf (config.layers.layer-10.system.config.impermanence.enable or false)
        {
          directories = [
            {
              directory = "/var/lib/localai";
              user = "root";
              group = "root";
              mode = "0750";
            }
          ];
        };
  };
}
