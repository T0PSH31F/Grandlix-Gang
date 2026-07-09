# Agents Tier Entry Point
{ lib, ... }:
let
  inherit (import ../../layers/80-lib/81-helpers/mkDendriticModule.nix { inherit lib; })
    mkDendriticModule
    ;
in
{
  imports = [
    (mkDendriticModule "claude-code" ./71-coding/claude-code.nix)
    (mkDendriticModule "codex" ./71-coding/codex.nix)
    (mkDendriticModule "fabric-ai" ./73-tooling/fabric-ai.nix)
    (mkDendriticModule "gemini-cli" ./71-coding/gemini-cli.nix)
    (mkDendriticModule "mcp" ./73-tooling/mcp.nix)
    (mkDendriticModule "opencode" ./71-coding/opencode.nix)
    (mkDendriticModule "antigravity" ./71-coding/antigravity.nix)
    (mkDendriticModule "supergraph" ./71-coding/supergraph.nix)
    (mkDendriticModule "agent-audio" ./72-voice/asr-tts/agent-audio.nix)
    ./packages-ai.nix
    ./74-ai-infra
    ./75-mcp
    ./76-hermes-agent
  ];
}
