{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.paperclip;
in
{
  options.services.ai-services.paperclip = {
    enable = mkEnableOption "Paperclip — orchestrate AI agent teams";

    port = mkOption {
      type = types.port;
      default = 3100;
      description = "Port for Paperclip web UI";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/paperclip";
      description = "Persistent data directory";
    };

    databaseUrl = mkOption {
      type = types.str;
      default = "postgres://paperclip:paperclip@localhost:5432/paperclip";
      description = "PostgreSQL connection string (requires services.ai-services.postgresql)";
    };

    authSecret = mkOption {
      type = types.str;
      default = "change-me-in-production";
      description = "BETTER_AUTH_SECRET for Paperclip authentication";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.paperclip = {
      image = "ghcr.io/paperclipai/paperclip:latest";
      ports = [ "127.0.0.1:${toString cfg.port}:3100" ];
      environment = {
        PORT = "3100";
        NODE_ENV = "production";
        SERVE_UI = "true";
        DATABASE_URL = cfg.databaseUrl;
        BETTER_AUTH_SECRET = cfg.authSecret;
        PAPERCLIP_DEPLOYMENT_MODE = "authenticated";
        PAPERCLIP_DEPLOYMENT_EXPOSURE = "private";
        PAPERCLIP_PUBLIC_URL = "http://localhost:${toString cfg.port}";
      };
      volumes = [
        "${cfg.dataDir}:/app/data"
      ];
      extraOptions = [ "--network=host" ];
      autoStart = true;
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root -"
    ];

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
