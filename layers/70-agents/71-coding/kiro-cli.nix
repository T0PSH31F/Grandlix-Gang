# Kiro CLI — Command-line interface for Kiro agentic IDE
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.layers.layer-70.agent.kiro-cli;
in
{
  options.layers.layer-70.agent.kiro-cli = {
    enable = mkEnableOption "Kiro CLI — command-line interface for Kiro agentic IDE";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      kiro-cli
    ];
  };
}
