{ lib, ... }:
{
  imports = [
    ./ai.nix
  ];

  services = {
    llm-agents.enable = lib.mkDefault true;
    sillytavern-app.enable = lib.mkDefault true;
    wyoming-services.enable = lib.mkDefault true;
    ai-services = {
      enable = lib.mkDefault true;
      ollama.enable = lib.mkDefault true;
      chromadb.enable = lib.mkDefault true;
      lmstudio.enable = lib.mkDefault true;
      jan.enable = lib.mkDefault true;
      aider.enable = lib.mkDefault true;
    };
  };
}
