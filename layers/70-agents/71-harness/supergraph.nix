# Tier: 71-harness
# Module: supergraph.nix
# Purpose: Supergraph autonomous codebase navigation harness.
# Option Path: layers.layer-70.agent.supergraph
# Enabling Host Tags: ai-agent, development
# RAM Footprint: medium (300MB-1GB)
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.layers.layer-70.agent.supergraph = {
    enable = lib.mkEnableOption "supergraph — monorepo intelligence for AI coding agents";
  };

  config = lib.mkIf config.layers.layer-70.agent.supergraph.enable {
    environment.systemPackages = [ pkgs.supergraph ];
  };
}
