{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.ai-services;
in
{
  options.services.ai-services = {
    enable = mkEnableOption "AI-related services (master switch for all sub-services)";

    # Retained for backward compatibility — the actual SillyTavern service
    # is at `services.sillytavern` or `services.sillytavern-app`.
    # This option was defined in the old monolithic ai-services.nix but
    # never wired to any service config; it exists here solely so existing
    # machine configs that reference `services.ai-services.sillytavern.enable`
    # do not break during the refactoring.
    sillytavern = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Stub — see services.sillytavern for the actual service";
      };
      port = mkOption {
        type = types.int;
        default = 8000;
      };
      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/sillytavern";
      };
    };

  };

  config = mkIf cfg.enable {
    services.ai-services = {
      postgresql.enable = mkDefault true;
      open-webui.enable = mkDefault true;
      qdrant.enable = mkDefault false; # Deactivated fleet-wide — memory moved to Honcho + brain-service (PostgreSQL/pgvector)
      chromadb.enable = mkDefault false; # Deactivated fleet-wide — see qdrant note
      localai.enable = mkDefault true;
      ollama.enable = mkDefault true;
      ollama-ui.enable = mkDefault true;
      jan.enable = mkDefault true;
      cherry-studio.enable = mkDefault true;
      aider.enable = mkDefault true;
      # extreme-router.enable is controlled by kong-gateway.routers.codingRouter
    };
  };
}
