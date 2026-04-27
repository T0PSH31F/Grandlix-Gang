{ lib, ... }: {
  imports = [
    ../../20-services
    ../../70-agents
  ];

  features.agent = {
    opencode.enable = lib.mkDefault true;
    mcp.enable = lib.mkDefault true;
    claude-code.enable = lib.mkDefault true;
    gemini-cli.enable = lib.mkDefault true;
    asr-tts.enable = lib.mkDefault true;
  };

  features.system.ai-agent-stack.enable = lib.mkDefault true;
}
