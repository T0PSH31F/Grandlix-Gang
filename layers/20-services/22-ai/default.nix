# flake-parts/services/ai/default.nix
# AI and LLM services
{
  imports = [
    ./ai-services.nix
    ./brain-service.nix
    ./llm-agents.nix
    ./sillytavern.nix
    ./voice.nix
    ./wyoming.nix
    ./llama-cpp.nix
  ];
}
