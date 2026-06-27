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
}
