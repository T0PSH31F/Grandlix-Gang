{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.qdrant;
in
{
  options.services.ai-services.qdrant = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Qdrant vector database";
    };

    port = mkOption {
      type = types.int;
      default = 6333;
      description = "Qdrant port";
    };
  };

  config = mkIf cfg.enable {
    services.qdrant = {
      enable = true;
      settings = {
        service = {
          http_port = cfg.port;
          grpc_port = 6334;
        };
        storage = {
          storage_path = "/var/lib/qdrant/storage";
        };
      };
    };

    systemd.services.qdrant.serviceConfig = {
      ReadWritePaths = [ "/var/lib/qdrant" ];
    };

    environment.persistence."/persist" = mkIf (config.layers.layer-10.system.config.impermanence.enable or false) {
      directories = [
        {
          directory = "/var/lib/qdrant";
          user = "qdrant";
          group = "qdrant";
          mode = "0750";
        }
      ];
    };
  };
}