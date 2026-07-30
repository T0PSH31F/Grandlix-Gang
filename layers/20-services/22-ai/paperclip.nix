{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.paperclip;

  paperclipPkg = pkgs.buildNpmPackage rec {
    pname = "paperclipai";
    version = "2026.722.0";

    src = pkgs.fetchFromGitHub {
      owner = "paperclipai";
      repo = "paperclip";
      rev = "master";
      hash = "sha256-2sIELkht3RYds+PccJogeMDTAvttmDhRLVhwUqyl65g=";
    };

    npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # placeholder
    dontNpmBuild = false;

    meta = with lib; {
      description = "Open-source orchestration for teams of AI agents";
      homepage = "https://github.com/paperclipai/paperclip";
      license = licenses.mit;
      mainProgram = "paperclipai";
    };
  };
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
    systemd.services.paperclip = {
      description = "Paperclip — AI agent team orchestration";
      after = [ "network.target" "postgresql.service" ];
      wants = [ "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${lib.getExe paperclipPkg}";
        Restart = "always";
        RestartSec = 5;
        Environment = [
          "PORT=${toString cfg.port}"
          "NODE_ENV=production"
          "SERVE_UI=true"
          "DATABASE_URL=${cfg.databaseUrl}"
          "BETTER_AUTH_SECRET=${cfg.authSecret}"
          "PAPERCLIP_DEPLOYMENT_MODE=authenticated"
          "PAPERCLIP_DEPLOYMENT_EXPOSURE=private"
          "PAPERCLIP_PUBLIC_URL=http://localhost:${toString cfg.port}"
        ];
        StateDirectory = "paperclip";
        WorkingDirectory = "${paperclipPkg}";
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
