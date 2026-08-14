{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.paperclip;

  # PAPERCLIP IS DISABLED — pnpm monorepo with complex overrides/patches.
  #
  # The upstream repo (paperclipai/paperclip) doesn't ship pnpm-lock.yaml.
  # Generating one locally fails because the project uses pnpm overrides and
  # patchedDependencies that must match the lockfile exactly.
  #
  # To enable this package:
  # 1. Wait for upstream to commit pnpm-lock.yaml, OR
  # 2. Fork the repo and commit the lock file, OR
  # 3. Use OCI container approach (virtualisation.oci-containers)
  #
  # See: https://github.com/paperclipai/paperclip/issues (request lock file)
  paperclipPkg = null; # Placeholder — cannot build without upstream lock file
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
    # Paperclip cannot be built — see comment above paperclipPkg
    assertions = [{
      assertion = paperclipPkg != null;
      message = "paperclip is currently disabled: upstream doesn't ship pnpm-lock.yaml. See layers/20-services/22-ai/paperclip.nix for details.";
    }];

    systemd.services.paperclip = mkIf (paperclipPkg != null) {
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
