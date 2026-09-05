{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.lokb;
in
{
  options.services.ai-services.lokb = {
    enable = mkEnableOption "lokb — Local Offline Knowledge Base with MCP server";

    port = mkOption {
      type = types.port;
      default = 7890;
      description = "HTTP API port for lokb";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/lokb";
      description = "Directory for lokb data storage";
    };

    booksDir = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Directory containing PDF/EPUB books to ingest";
    };

    mcpEnable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable MCP server for Hermes integration";
    };

    threads = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "Number of parallel ingestion threads (default: num_cpus/2)";
    };

    llmBackend = mkOption {
      type = types.str;
      default = "ollama:phi3";
      description = "LLM backend for enrichment (e.g. ollama:phi3, openai:url:model)";
    };
  };

  config = mkIf cfg.enable {
    # Ensure the lokb package is available
    environment.systemPackages = [ pkgs.lokb ];

    # Create lokb user and group
    users.users.lokb = {
      isSystemUser = true;
      group = "lokb";
      description = "lokb Knowledge Base Service User";
      home = cfg.dataDir;
      createHome = true;
    };
    users.groups.lokb = { };

    # Systemd service for lokb MCP server (stdio mode for Hermes)
    systemd.services.lokb-mcp = mkIf cfg.mcpEnable {
      description = "lokb MCP Server (stdio)";
      # This is triggered on-demand by Hermes via stdin/stdout
      # No need to start at boot — Hermes launches it as needed
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.lokb}/bin/lokb serve --mcp";
        User = "lokb";
        Group = "lokb";
        StateDirectory = "lokb";
        ReadWritePaths = [ cfg.dataDir ];
        # Pass environment for Ollama LLM backend
        Environment = "LOKB_DATA_DIR=${cfg.dataDir}";
      };
    };

    # Systemd service for lokb HTTP API server
    systemd.services.lokb-serve = {
      description = "lokb HTTP API Server";
      wantedBy = mkIf (!cfg.mcpEnable) [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = {
        LOKB_DATA_DIR = cfg.dataDir;
      }
      // optionalAttrs (cfg.threads != null) {
        LOKB_THREADS = toString cfg.threads;
      };

      serviceConfig = {
        ExecStart = "${pkgs.lokb}/bin/lokb serve --port ${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = 5;
        User = "lokb";
        Group = "lokb";
        StateDirectory = "lokb";
        ReadWritePaths = [ cfg.dataDir ] ++ optional (cfg.booksDir != null) cfg.booksDir;
      };
    };

    # Impermanence: persist lokb data
    environment.persistence."/persist" =
      mkIf (config.layers.layer-10.system.config.impermanence.enable or false)
        {
          directories = [
            {
              directory = cfg.dataDir;
              user = "lokb";
              group = "lokb";
              mode = "0750";
            }
          ];
        };
  };
}
