# 🧠 Claude Code — Anthropic Agentic Coding Tool
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-70.agent.claude-code;
in
{
  options.layers.layer-70.agent.claude-code = {
    enable = lib.mkEnableOption "Anthropic Claude Code agentic coding tool";
  };

  nixos = lib.mkIf cfg.enable {
    environment.systemPackages = lib.optional (pkgs ? claude-code) pkgs.claude-code;
  };

  home = lib.mkIf cfg.enable {
    home.packages = lib.optional (
      pkgs ? vscode-extension-anthropic-claude-code
    ) pkgs.vscode-extension-anthropic-claude-code;

    xdg.configFile."claude/settings.json".text = builtins.toJSON {
      hasCompletedOnboarding = true;
      env = {
        ANTHROPIC_BASE_URL = "http://127.0.0.1:20128/v1";
      };
    };
  };
}
