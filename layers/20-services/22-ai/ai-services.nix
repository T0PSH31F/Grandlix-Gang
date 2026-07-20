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

    # FreeLLMAPI — free-tier LLM router (28 providers, 339 models, :3001)
    freellmapi = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable FreeLLMAPI LLM router service";
      };
      port = mkOption {
        type = types.int;
        default = 3001;
      };
    };

    # Mistral MCP — Mistral AI tool server (HTTP mode, :3333)
    mistral-mcp = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Mistral MCP HTTP service";
      };
      port = mkOption {
        type = types.int;
        default = 3333;
      };
    };
  };

  config = mkIf cfg.enable {
    services.ai-services = {
      postgresql.enable = mkDefault true;
      open-webui.enable = mkDefault true;
      qdrant.enable = mkDefault true;
      chromadb.enable = mkDefault true;
      localai.enable = mkDefault true;
      ollama.enable = mkDefault true;
      ollama-ui.enable = mkDefault true;
      lmstudio.enable = mkDefault true;
      jan.enable = mkDefault true;
      cherry-studio.enable = mkDefault true;
      aider.enable = mkDefault true;
      context-forge.enable = mkDefault false; # opt-in, not enabled by default
    };
  };
}
