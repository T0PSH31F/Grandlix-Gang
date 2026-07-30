{ lib, ... }:
{
  # ai-agent — coding and agent tooling only
  # Does NOT enable LLM backends (that's ai-server)
  imports = [
    ../../70-agents
    ../../70-agents/75-mcp
    ../../70-agents/76-hermes-agent
  ];

  layers.layer-70.agent = {
    opencode.enable = lib.mkDefault true;
    mcp.enable = lib.mkDefault true;
    claude-code.enable = lib.mkDefault true;
    gemini-cli.enable = lib.mkDefault true;
    asr-tts.enable = lib.mkDefault false;
  };

  layers.layer-75.mcp.enable = lib.mkDefault true;

  layers.layer-76.hermes.enable = lib.mkDefault true;

  layers.layer-77.herm.enable = lib.mkDefault true;
  layers.layer-77.open-skills.enable = lib.mkDefault true;

  layers.layer-78.hermes-webui.enable = lib.mkDefault true;

  # Override ai-services.nix's mkDefault false to enable these opt-in services
  services.ai-services.mission-control.enable = lib.mkForce true;
  services.ai-services.aionui.enable = lib.mkForce true;
  services.ai-services.paperclip.enable = lib.mkForce true;
}
