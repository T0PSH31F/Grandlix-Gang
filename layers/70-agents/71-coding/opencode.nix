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
    lib.mkIf osConfig.layers.layer-70.agent.opencode.enable {
      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;
        web.enable = true;

        agents = ./opencode/agents;
        tools = ./opencode/tools;
        skills = ./opencode/skills;
        commands = ./opencode/commands;
        context = ./opencode/rules.md;

        tui.theme = lib.mkForce "noctalia";

        settings = {
          mcp = {
            himalaya = {
              command = [
                "node"
                "/home/t0psh31f/Projects/himalaya-mcp/dist/index.js"
              ];
              enabled = true;
              type = "local";
              env = {
                HIMALAYA_ACCOUNT = "wrighterik77";
                HIMALAYA_FOLDER = "INBOX";
                HIMALAYA_BINARY = "/etc/profiles/per-user/t0psh31f/bin/himalaya";
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
            "opencode-antigravity-auth"
            "octto"
          ];

          agent = {
            explore.disable = true;
            general.disable = true;
          };
          lsp = true;
          tui.keybinds.command_list = "ctrl+shift+p";
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
