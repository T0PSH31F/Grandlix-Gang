# agent-orchestrator — runtime/orchestration for AI agents
# Deployed on always-on machines that host the agent control plane.
# Does NOT run LLM backends (that's ai-router) or vector RAG (that's pkb-node).
{ config, lib, ... }:
{
  config = lib.mkIf (lib.elem "agent-orchestrator" config.machine.tags) {
    # Hermes server daemon
    layers.layer-76.hermes.enable = lib.mkDefault true;
    # MCP framework
    layers.layer-75.mcp.enable = lib.mkDefault true;
    # Sandbox for agent code execution
    layers.layer-70.agent.sandbox.enable = lib.mkDefault true;
    # Agent control-plane services
    layers.layer-20.services.mission-control.enable = lib.mkDefault true;
    layers.layer-20.services.paperclip.enable = lib.mkDefault true;
    layers.layer-20.services.aionui.enable = lib.mkDefault true;
  };
}
