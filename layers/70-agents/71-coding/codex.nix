# 🧠 OpenAI Codex — Coding Agent
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-70.agent.codex;
in
{
  options.layers.layer-70.agent.codex = {
    enable = lib.mkEnableOption "OpenAI Codex coding agent";
  };

  nixos = lib.mkIf cfg.enable {
    environment.systemPackages = lib.optional (pkgs ? codex) pkgs.codex;
  };

  home = lib.mkIf cfg.enable {
    xdg.configFile."deepseek/config.toml".text = ''
      [providers.openai]
      base_url = "http://127.0.0.1:20128/v1"
    '';
  };
}
