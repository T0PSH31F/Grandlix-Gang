{
  lib,
  pkgs,
  ...
}:
{
  options.layers.layer-70.agent.opencode = {
    enable = lib.mkEnableOption "OpenCode AI coding agent";
    desktop = lib.mkEnableOption "OpenCode desktop application";

    agents = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Custom agents for opencode";
    };
  };

  home =
    { config, osConfig, ... }:
    let
      pluginLabel = "oh-my-opencode-slim@latest";
    in
    {
      config = lib.mkIf osConfig.layers.layer-70.agent.opencode.enable {
        programs.opencode = {
        enable = true;
        enableMcpIntegration = true;
        web.enable = true;

        agents = ./opencode/agents;
        tools = ./opencode/tools;
        skills = config.lib.file.mkOutOfStoreSymlink "/persist/home/t0psh31f/.config/opencode/skills";
        commands = ./opencode/commands;
        context = ./opencode/rules.md;

        tui = {
          theme = lib.mkForce "noctalia";
          keybinds.command_list = "ctrl+shift+p";
        };
      };

      home.activation.initOpenCodeSkills = {
        data = ''
          SKILLS_DIR="/persist/home/t0psh31f/.config/opencode/skills"
          if [ ! -d "$SKILLS_DIR" ]; then
            $DRY_RUN_CMD mkdir -p "$SKILLS_DIR"
            $DRY_RUN_CMD cp -r ${./opencode/skills}/* "$SKILLS_DIR"/ 2>/dev/null || true
            $DRY_RUN_CMD chmod -R u+w "$SKILLS_DIR"
          fi
        '';
        before = [ ];
        after = [ "writeBoundary" ];
      };

        settings = {
          mcp = {
            # ── CodeGraph: Semantic code intelligence ─────────────────
            codegraph = {
              command = [
                "codegraph"
                "serve"
                "--mcp"
              ];
              enabled = true;
              type = "local";
            };
            himalaya = {
              command = [
                "node"
                "/home/t0psh31f/Projects/AI/Hermes-Agent/himalaya-mcp/dist/index.js"
              ];
              enabled = true;
              type = "local";
              env = {
                HIMALAYA_ACCOUNT = "wrighterik77";
                HIMALAYA_FOLDER = "INBOX";
                HIMALAYA_BINARY = "${pkgs.himalaya}/bin/himalaya";
              };
            };
            # ── Tool Discovery & Orchestration ───────────────────────
            # NCP — semantic MCP gateway: reduces 50+ tools to 2 unified tools
            # (find + code). Saves ~97% of context token overhead.
            ncp = {
              command = [
                "npx"
                "-y"
                "@portel/ncp"
              ];
              enabled = true;
              type = "local";
            };
            # Forage — self-improving tool discovery: agents can search,
            # install, and learn new MCP servers autonomously.
            forage = {
              command = [
                "npx"
                "-y"
                "forage-mcp"
              ];
              enabled = true;
              type = "local";
            };
            # Mistral MCP — full Mistral AI surface (chat, OCR, Codestral, etc.)
            # Also available via systemd HTTP service on :3333 for Hermes.
            mistral = {
              command = [
                "npx"
                "-y"
                "mistral-mcp@latest"
              ];
              enabled = true;
              type = "local";
              env.MISTRAL_API_KEY = ""; # Set via environmentFile or sops
            };
            # Headroom MCP — context compression (20-95% token savings)
            # Tools: headroom_compress, headroom_retrieve, headroom_stats
            headroom = {
              command = [
                "headroom"
                "mcp"
                "serve"
              ];
              enabled = true;
              type = "local";
            };

            # ── Disabled ───────────────────────────────────────────
            browser-use.enabled = false; # 100% error rate, not needed
            file-manager.enabled = false; # not useful
            ha-mcp.enabled = false; # not needed
            mcp-registry.enabled = false; # never worked
            # sequential-thinking.enabled = false;  # available if wanted
          };
          plugin = [
            pluginLabel
            "@pantheon-ai/opencode-warcraft-notifications"
            "opencode-antigravity-auth@latest"
            "octto"
            "file:~/.config/opencode/plugins/context-capture"
          ];

          agent = {
            explore.disable = true;
            general.disable = true;
          };
          lsp = true;

          # Model metadata limits (context & output limits) source URLs to verify on bumps:
          # Google Gemini models: https://ai.google.dev/gemini-api/docs/models/experimental-models
          # Anthropic Claude models: https://docs.anthropic.com/en/docs/about-claude/models
          provider.google.models = {
            antigravity-gemini-3-pro = {
              name = "Gemini 3 Pro (Antigravity)";
              limit = { context = 1048576; output = 65535; };
              modalities = { input = [ "text" "image" "pdf" ]; output = [ "text" ]; };
              variants = {
                low = { thinkingLevel = "low"; };
                high = { thinkingLevel = "high"; };
              };
            };
            "antigravity-gemini-3.1-pro" = {
              name = "Gemini 3.1 Pro (Antigravity)";
              limit = { context = 1048576; output = 65535; };
              modalities = { input = [ "text" "image" "pdf" ]; output = [ "text" ]; };
              variants = {
                low = { thinkingLevel = "low"; };
                high = { thinkingLevel = "high"; };
              };
            };
            antigravity-gemini-3-flash = {
              name = "Gemini 3 Flash (Antigravity)";
              limit = { context = 1048576; output = 65536; };
              modalities = { input = [ "text" "image" "pdf" ]; output = [ "text" ]; };
              variants = {
                minimal = { thinkingLevel = "minimal"; };
                low = { thinkingLevel = "low"; };
                medium = { thinkingLevel = "medium"; };
                high = { thinkingLevel = "high"; };
              };
            };
            "antigravity-gemini-3.7-flash" = {
              name = "Gemini 3.7 Flash (Antigravity)";
              limit = { context = 1048576; output = 65536; };
              modalities = { input = [ "text" "image" "pdf" ]; output = [ "text" ]; };
              variants = {
                minimal = { thinkingLevel = "minimal"; };
                low = { thinkingLevel = "low"; };
                medium = { thinkingLevel = "medium"; };
                high = { thinkingLevel = "high"; };
              };
            };
            "antigravity-gemini-3.7-pro" = {
              name = "Gemini 3.7 Pro (Antigravity)";
              limit = { context = 1048576; output = 65536; };
              modalities = { input = [ "text" "image" "pdf" ]; output = [ "text" ]; };
              variants = {
                low = { thinkingLevel = "low"; };
                high = { thinkingLevel = "high"; };
              };
            };
            antigravity-claude-sonnet-4-6 = {
              name = "Claude Sonnet 4.6 (Antigravity)";
              limit = { context = 200000; output = 64000; };
              modalities = { input = [ "text" "image" "pdf" ]; output = [ "text" ]; };
            };
            antigravity-claude-opus-4-6-thinking = {
              name = "Claude Opus 4.6 Thinking (Antigravity)";
              limit = { context = 200000; output = 64000; };
              modalities = { input = [ "text" "image" "pdf" ]; output = [ "text" ]; };
              variants = {
                low = { thinkingConfig = { thinkingBudget = 8192; }; };
                max = { thinkingConfig = { thinkingBudget = 32768; }; };
              };
            };
            "gemini-2.5-flash" = {
              name = "Gemini 2.5 Flash (Gemini CLI)";
              limit = { context = 1048576; output = 65536; };
              modalities = { input = [ "text" "image" "pdf" ]; output = [ "text" ]; };
            };
            "gemini-2.5-pro" = {
              name = "Gemini 2.5 Pro (Gemini CLI)";
              limit = { context = 1048576; output = 65536; };
              modalities = { input = [ "text" "image" "pdf" ]; output = [ "text" ]; };
            };
            gemini-3-flash-preview = {
              name = "Gemini 3 Flash Preview (Gemini CLI)";
              limit = { context = 1048576; output = 65536; };
              modalities = { input = [ "text" "image" "pdf" ]; output = [ "text" ]; };
            };
            gemini-3-pro-preview = {
              name = "Gemini 3 Pro Preview (Gemini CLI)";
              limit = { context = 1048576; output = 65535; };
              modalities = { input = [ "text" "image" "pdf" ]; output = [ "text" ]; };
            };
            "gemini-3.1-pro-preview" = {
              name = "Gemini 3.1 Pro Preview (Gemini CLI)";
              limit = { context = 1048576; output = 65535; };
              modalities = { input = [ "text" "image" "pdf" ]; output = [ "text" ]; };
            };
            "gemini-3.1-pro-preview-customtools" = {
              name = "Gemini 3.1 Pro Preview Custom Tools (Gemini CLI)";
              limit = { context = 1048576; output = 65535; };
              modalities = { input = [ "text" "image" "pdf" ]; output = [ "text" ]; };
            };
          };

          # Kong AI Gateway — unified LLM provider
          # Routes to ExtremeRouter (coding), FreeLLMAPI (free), etc.
          provider.kong = lib.mkIf (osConfig.services.ai-services.kong-gateway.enable or false) {
            baseUrl = "http://127.0.0.1:${toString osConfig.services.ai-services.kong-gateway.proxyPort}/v1";
            name = "Kong AI Gateway";
            models = { };
          };

          # ExtremeRouter — 154+ providers, RTK savings, smart fallback
          provider.extreme-router = lib.mkIf (osConfig.services.ai-services.extreme-router.enable or false) {
            baseUrl = "http://127.0.0.1:${toString osConfig.services.ai-services.extreme-router.port}/v1";
            name = "ExtremeRouter";
            models = { };
          };
        };
      };

      xdg.configFile = {
        "opencode/plugin.json".text = builtins.toJSON {
          "@pantheon-ai/opencode-warcraft-notifications" = {
            faction = "horde";
            showDescriptionInToast = true;
          };
        };
        "opencode/themes/noctalia.json".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/noctalia/templates/opencode-theme.json";
        "opencode/oh-my-opencode-slim.json".source = ./opencode/oh-my-opencode-slim.json;

        # Context-capture plugin — automatic session persistence to context-mode FTS5
        "opencode/plugins/context-capture/package.json".text = builtins.toJSON {
          name = "opencode-context-capture";
          version = "1.0.0";
          type = "module";
          main = "context-capture.js";
          exports = {
            "." = "./context-capture.js";
          };
        };
        "opencode/plugins/context-capture/context-capture.js".source = ./opencode/plugins/context-capture.js;
      };

      home.packages =
        lib.optional osConfig.layers.layer-70.agent.opencode.desktop pkgs.opencode-desktop
        ++ [
          pkgs.libcanberra-gtk3 # canberra-gtk-play for warcraft-notifications fallback
          pkgs.alsa-utils # aplay for warcraft-notifications wav playback
          pkgs.pulseaudio # paplay (silent playback, preferred by warcraft-notifications)

          # oh-my-opencode-slim CLI + companion binary
          (pkgs.writeShellScriptBin "omos" ''
            exec ${pkgs.nodejs}/bin/npx oh-my-opencode-slim@latest "$@"
          '')
          (pkgs.writeShellScriptBin "oh-my-opencode-slim" ''
            exec ${pkgs.nodejs}/bin/npx oh-my-opencode-slim@latest "$@"
          '')
        ];
      };
    }
