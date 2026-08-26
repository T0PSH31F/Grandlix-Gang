{ config, lib, ... }:
{
  # ai-agent — coding and agent tooling profile
  # Does NOT enable LLM inference backends (that's ai-server profile)
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
    codegraph.enable = lib.mkDefault true;
    kiro-cli.enable = lib.mkDefault true;
    dsh.enable = lib.mkDefault true;
    asr-tts.enable = lib.mkDefault false;
    ai-agent-stack.enable = lib.mkDefault true;
  };

  layers.layer-75.mcp.enable = lib.mkDefault true;
  layers.layer-76.hermes.enable = lib.mkDefault true;
  layers.layer-76.hermes.enableDesktop = lib.mkDefault true;
  layers.layer-76.hermes-workspace.enable = lib.mkDefault true;
  layers.layer-76.hermes-dashboard.enable = lib.mkDefault true;
  layers.layer-76.hermes-live-voice.enable = lib.mkDefault true;
  layers.layer-76.open-skills.enable = lib.mkDefault true;

  # Orchestration & control plane services
  services.ai-services.mission-control.enable = lib.mkDefault true;
  services.ai-services.aionui.enable = lib.mkDefault true;
  services.ai-services.paperclip.enable = lib.mkDefault true;

  # Memory chassis & gateway services
  layers.layer-20.services.memory-vault.enable = lib.mkDefault true;
  layers.layer-20.services.everos.enable = lib.mkDefault true;
  layers.layer-20.services.context-forge.enable = lib.mkDefault true;
  layers.layer-20.services.memory-governance.enable = lib.mkDefault true;
  layers.layer-70.agent.sandbox.enable = lib.mkDefault true;

  # Agent productivity & messaging daemons
  layers.layer-20.services.todo-system.enable = lib.mkDefault true;
  layers.layer-20.services.communication.signal-cli-daemon = {
    enable = lib.mkDefault true;
    port = lib.mkDefault 8080;
  };
  layers.layer-20.services.communication.camofox-browser = {
    enable = lib.mkDefault true;
    port = lib.mkDefault 9377;
    apiKey = config.sops.placeholder.camofox_api_key or "";
  };
}
