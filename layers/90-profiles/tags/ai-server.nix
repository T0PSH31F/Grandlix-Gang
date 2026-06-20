{ lib, ... }:
{
  imports = [
    ./ai.nix
  ];

  layers.layer-20.services.config = {
    homepage-dashboard.enable = lib.mkDefault true;
    homepage-dashboard.lovable.enable = lib.mkDefault true;
  };

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
