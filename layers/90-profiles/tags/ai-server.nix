# ai-server — local LLM backends, vector DBs, and AI router services
# Tags-as-data: all config gated by tag membership.
{ config, lib, ... }:
{
  config = lib.mkIf (builtins.elem "ai-server" config.machine.tags) {
    services = {
      llm-agents.enable = lib.mkDefault true;
      ai-services = {
        enable = lib.mkDefault true;
        ollama.enable = lib.mkDefault true;
        chromadb.enable = lib.mkDefault false; # Deactivated — durable memory is Honcho + brain-service (pgvector)
        open-webui.enable = lib.mkDefault true;
        jan.enable = lib.mkDefault true;
        aider.enable = lib.mkDefault true;
        postgresql.enable = lib.mkDefault true;
        # context-forge retired (folded into brain-service MCP + memory-vault)

        # AI Gateway & Upstream Routers
        kong-gateway = {
          enable = lib.mkDefault true;
          proxyPort = lib.mkDefault 8090;
          routers.codingRouter = lib.mkDefault "extreme-router";
        };

        freellmapi = {
          enable = lib.mkDefault true;
          port = lib.mkDefault 3003;
        };

        mistral-mcp = {
          enable = lib.mkDefault true;
          port = lib.mkDefault 3333;
        };

        headroom = {
          enable = lib.mkDefault true;
          port = lib.mkDefault 8787;
        };

        brain-service = {
          enable = lib.mkDefault true;
          port = lib.mkDefault 8010;
          mcpEnable = lib.mkDefault true;
          booksDir = lib.mkDefault "/home/t0psh31f/Notes/PKB";
          embedModel = lib.mkDefault "nomic-embed-text";
          embedDim = lib.mkDefault 768;
        };

        polyfloor = {
          enable = lib.mkDefault true;
          port = lib.mkDefault 8001;
        };
      };

      infrastructure.langfuse.enable = lib.mkDefault true;
    };

    layers.layer-20.services.extreme-router = {
      enable = lib.mkDefault true;
      port = lib.mkDefault 20128;
    };

    layers.layer-20.services.memory-governance.enable = lib.mkDefault true;
  };
}
