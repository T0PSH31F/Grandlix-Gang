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
}
