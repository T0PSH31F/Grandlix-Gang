{ lib, ... }: {
  imports = [
    ../../20-services
    ../../70-agents
  ];

  layers.layer-70.agent = {
    opencode.enable = lib.mkDefault true;
    mcp.enable = lib.mkDefault true;
    claude-code.enable = lib.mkDefault true;
    gemini-cli.enable = lib.mkDefault true;
    asr-tts.enable = lib.mkDefault true;
  };

  layers.layer-10.system.ai-agent-stack.enable = lib.mkDefault true;
}
