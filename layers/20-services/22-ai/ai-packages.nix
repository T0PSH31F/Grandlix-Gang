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
      qdrant
      ramalama
      bluemail
      librechat
      nextjs-ollama-llm-ui
      skills
      beads
      gemini-cli
      python314Packages.pydantic-graph
    ];

    # Firewall: NextJS UI is always at 3004 when ai-services is enabled
    networking.firewall.allowedTCPPorts = [ 3004 ];
  };
}
