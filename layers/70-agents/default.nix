# Agents Tier Entry Point
{ lib, mkDendriticModule, ... }:
{
  imports = [
    (mkDendriticModule "claude-code" ./71-coding/claude-code.nix)
    (mkDendriticModule "codex" ./71-coding/codex.nix)
    (mkDendriticModule "fabric-ai" ./73-tooling/fabric-ai.nix)
    (mkDendriticModule "gemini-cli" ./71-coding/gemini-cli.nix)
    (mkDendriticModule "mcp" ./73-tooling/mcp.nix)
    (mkDendriticModule "opencode" ./71-coding/opencode.nix)
    (mkDendriticModule "antigravity" ./71-coding/antigravity.nix)
    (mkDendriticModule "codegraph" ./71-coding/codegraph.nix)
    (mkDendriticModule "kiro-cli" ./71-coding/kiro-cli.nix)
    (mkDendriticModule "dsh" ./71-coding/dsh.nix)
    (mkDendriticModule "agent-audio" ./72-voice/asr-tts/agent-audio.nix)
    ./packages-ai.nix
    ./74-ai-infra
    ./75-mcp
    ./76-hermes-agent
  ];
}
