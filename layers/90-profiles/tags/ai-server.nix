{ lib, config, ... }:
{
  # ai-server — local LLM backends, vector DBs, and AI router services
  imports = [ ];

  services = {
    llm-agents.enable = lib.mkDefault true;
    sillytavern-app.enable = lib.mkForce false; # Disabled: crash-looping
    wyoming-services.enable = lib.mkDefault true;

    ai-services = {
      enable = lib.mkDefault true;
      ollama.enable = lib.mkDefault true;
      chromadb.enable = lib.mkDefault true;
      open-webui.enable = lib.mkDefault true;
      jan.enable = lib.mkDefault true;
      aider.enable = lib.mkDefault true;
      postgresql.enable = lib.mkDefault true;
      opencompany.enable = lib.mkForce false; # Disabled: replaced by polyfloor
      context-forge.enable = lib.mkDefault true;
      qdrant.enable = lib.mkForce false; # Disabled: LLVM intrinsic signature mismatch
      lmstudio.enable = lib.mkForce false; # Disabled: packaging error in unstable

      # AI Gateway & Upstream Routers
      kong-gateway = {
        enable = lib.mkDefault true;
        proxyPort = lib.mkDefault 8090;
        routers.codingRouter = lib.mkDefault "extreme-router";
      };

      extreme-router = {
        enable = lib.mkDefault true;
        port = lib.mkDefault 20128;
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
}
