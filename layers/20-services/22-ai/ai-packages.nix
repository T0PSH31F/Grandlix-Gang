# Unified AI Packages Catalog
# Consolidates legacy ai-packages.nix, llm-agents.nix, and packages-ai.nix
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-20.services.ai-packages;
  legacyAiServicesCfg = config.services.ai-services;
  legacyLlmAgentsCfg = config.services.llm-agents;
  hasTag = tag: builtins.elem tag (config.machine.tags or [ ]);
  llmPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system} or { };
in
{
  options.layers.layer-20.services.ai-packages = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable unified AI system packages catalog";
    };

    packages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Extra custom AI packages to add to system environment";
    };

    enableCodingAgents = mkOption {
      type = types.bool;
      default = true;
      description = "Enable CLI coding agents (claude-code, opencode, goose-cli, jules, pi, ccusage)";
    };

    enableServerTools = mkOption {
      type = types.bool;
      default = hasTag "ai-server";
      description = "Enable AI server tools (ollama, espeak-ng, pipx)";
    };
  };

  options.services.llm-agents = {
    enable = mkEnableOption "Agentic AI-related services (legacy compatibility alias)";
  };

  config = mkMerge [
    (mkIf (cfg.enable || legacyAiServicesCfg.enable or false || legacyLlmAgentsCfg.enable or false) {
      environment.systemPackages =
        with pkgs;
        [
          fabric-ai
          go-hass-agent
          ramalama
          bluemail
          librechat
          nextjs-ollama-llm-ui
          skills
          beads
          openshell
          gemini-cli
          python314Packages.pydantic-graph
        ]
        ++ cfg.packages
        ++ optionals cfg.enableCodingAgents (
          filter (p: p != null) [
            (llmPkgs.claude-code or pkgs.claude-code or null)
            (llmPkgs.goose-cli or null)
            (llmPkgs.jules or null)
            (llmPkgs.opencode or pkgs.opencode or null)
            (llmPkgs.pi or null)
            (llmPkgs.ccusage or null)
            (llmPkgs.beads or null)
          ]
        )
        ++ optionals cfg.enableServerTools [
          ollama
          espeak-ng
          pipx
        ];

      networking.firewall.allowedTCPPorts = [ 3004 ];
    })
    {
      services.hyprwhspr-rs.enable = mkDefault true;
    }
  ];
}
