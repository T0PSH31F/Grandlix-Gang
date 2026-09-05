# 🧠 OpenAI Codex — Coding Agent
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.layers.layer-70.agent.codex = {
    enable = lib.mkEnableOption "OpenAI Codex coding agent";
  };

  nixos =
    let
      cfg = config.layers.layer-70.agent.codex;
    in
    lib.mkIf cfg.enable {
      environment.systemPackages = lib.optional (pkgs ? codex) pkgs.codex;
    };

  home =
    let
      cfg = config.layers.layer-70.agent.codex;
    in
    lib.mkIf cfg.enable {
      xdg.configFile."deepseek/config.toml".text = ''
        [providers.openai]
        base_url = "http://127.0.0.1:20128/v1"
      '';
    };
}
