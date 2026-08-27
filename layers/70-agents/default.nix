# Agents Tier Entry Point — imports agent sub-tiers
{ ... }:
{
  imports = [
    ./71-coding
    ./72-voice
    ./73-tooling
    ./74-ai-infra
    ./75-mcp
    ./76-hermes-agent
    ./packages-ai.nix
  ];
}
