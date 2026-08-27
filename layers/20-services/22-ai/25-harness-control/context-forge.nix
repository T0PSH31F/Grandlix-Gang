# ContextForge MCP / A2A gateway for agent memory federation and tracing.
# Registers EverOS MCP server backend and enforces agent memory scoping rules.

{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-20.services.context-forge;

  # ContextForge MCP configuration JSON
  configFile = pkgs.writeText "context-forge-config.json" (
    builtins.toJSON {
      mcpServers = {
        everos = {
          command = "npx";
          args = [
            "-y"
            "@evermind-ai/everos-mcp"
          ];
          env = {
            EVEROS_BASE_URL = "http://127.0.0.1:8092";
            VAULT_PATH = "/var/lib/memory/vault";
          };
        };
      };
      scopes = {
        hermes = [
          "shared"
          "hermes-private"
        ];
        opencode = [ "shared" ];
        claude-code = [ "shared" ];
        sandboxed = [ "shared" ];
      };
      tracing = {
        enabled = true;
        provider = "langfuse";
        endpoint = "http://127.0.0.1:3005";
      };
    }
  );
in
{
  options.layers.layer-20.services.context-forge = {
    enable = mkEnableOption "ContextForge MCP/A2A gateway";

    port = mkOption {
      type = types.port;
      default = 8094;
      description = "Port for ContextForge gateway";
    };

    langfuseEndpoint = mkOption {
      type = types.str;
      default = "http://127.0.0.1:3005";
      description = "Langfuse tracing endpoint";
    };
  };

  # Backwards compatibility alias
  options.services.ai-services.context-forge = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Alias for layers.layer-20.services.context-forge.enable";
    };
    port = mkOption {
      type = types.port;
      default = 8094;
      description = "Alias for layers.layer-20.services.context-forge.port";
    };
  };

  config = mkMerge [
    (mkIf config.services.ai-services.context-forge.enable {
      layers.layer-20.services.context-forge.enable = true;
      layers.layer-20.services.context-forge.port = config.services.ai-services.context-forge.port;
    })
    (mkIf cfg.enable {
      virtualisation.oci-containers.containers.context-forge = {
        image = "ghcr.io/ibm/mcp-context-forge:latest";
        ports = [ "127.0.0.1:${toString cfg.port}:8083" ];
        extraOptions = [ "--network=host" ];
        environment = {
          PORT = toString cfg.port;
          CONFIG_FILE = "/app/config.json";
          LANGFUSE_HOST = cfg.langfuseEndpoint;
          JWT_SECRET_KEY = "nfp-context-forge-secret-key-32charslong!!";
          MCPGATEWAY_JWT_SECRET_KEY = "nfp-context-forge-secret-key-32charslong!!";
          SESSION_SECRET_KEY = "nfp-context-forge-secret-key-32charslong!!";
          AUTH_SECRET_KEY = "nfp-context-forge-secret-key-32charslong!!";
          SECURITY_KEY = "nfp-context-forge-secret-key-32charslong!!";
          ENVIRONMENT = "development";
        };
        volumes = [
          "${configFile}:/app/config.json"
        ];
      };

      networking.firewall.allowedTCPPorts = [ cfg.port ];
    })
  ];
}
