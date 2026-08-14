# Sops secrets for Polyfloor AI company OS
# Maps secrets from the central secrets file to Polyfloor's environment file.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.polyfloor;
  secretsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml;
  postgresSecretsFile = ../../../layers/00-cyberia/03-treasure/secrets/postgres.yaml;
in
{
  config = mkIf cfg.enable {
    # ── Polyfloor secrets ─────────────────────────────────────────────
    sops.secrets = {
      polyfloor_api_token = {
        sopsFile = secretsFile;
        owner = "polyfloor";
        group = "polyfloor";
        mode = "0400";
      };
      # Reuse the existing postgres password for the Polyfloor DB user
      postgres-password = {
        sopsFile = postgresSecretsFile;
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };

    # ── Environment file template for Polyfloor ───────────────────────
    # Uses sops placeholder substitution — actual values injected at activation.
    sops.templates."polyfloor-env" = {
      content = ''
        # Database connection (reuses shared PostgreSQL on z0r0)
        POLYFLOOR_DATABASE_DSN=postgresql://polyfloor:${config.sops.placeholder.postgres-password}@localhost:5432/polyfloor

        # API authentication
        POLYFLOOR_API_TOKEN=${config.sops.placeholder.polyfloor_api_token}

        # ExtremeRouter (free model gateway — already running on z0r0:20128)
        POLYFLOOR_EXTREMEROUTER_BASE_URL=http://127.0.0.1:20128/v1
        POLYFLOOR_HERMES_BASE_URL=http://127.0.0.1:11434/v1
        POLYFLOOR_HERMES_MODEL=hermes3

        # Policy
        POLYFLOOR_ALLOW_PAID_MODELS=false
        POLYFLOOR_PAID_DAILY_BUDGET_USD=0

        # Server
        POLYFLOOR_HOST=127.0.0.1
        POLYFLOOR_PORT=${toString cfg.port}
        POLYFLOOR_LOG_LEVEL=info
      '';
      owner = "polyfloor";
      group = "polyfloor";
      mode = "0400";
    };
  };
}
