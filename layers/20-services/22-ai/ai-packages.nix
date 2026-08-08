{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fabric-ai
      go-hass-agent
      # qdrant  # DROPPED: service mkForce false, package pointless to build
      ramalama
      bluemail
      librechat
      nextjs-ollama-llm-ui
      skills
      beads
      openshell
      # beadwork  # uncomment after `nix flake update nixpkgs` (needs commit 891eaa7+)
      gemini-cli
      python314Packages.pydantic-graph
    ];

    # Firewall: NextJS UI is always at 3004 when ai-services is enabled
    networking.firewall.allowedTCPPorts = [ 3004 ];
  };
}
