# Kiro CLI — Command-line interface for Kiro agentic IDE
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.kiro-cli;
in
{
  options.programs.kiro-cli = {
    enable = mkEnableOption "Kiro CLI — command-line interface for Kiro agentic IDE";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      kiro-cli
    ];
  };
}
