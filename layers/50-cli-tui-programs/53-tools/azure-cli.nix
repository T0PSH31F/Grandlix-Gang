# Azure CLI with extensions for containers, AI, and VMs
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.layers.layer-50.cli.azure-cli;
in
{
  options.layers.layer-50.cli.azure-cli = {
    enable = mkEnableOption "Azure CLI with extensions";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      azure-cli

      # Container extensions
      azure-cli-extensions.acr          # Azure Container Registry
      azure-cli-extensions.aks          # Azure Kubernetes Service
      azure-cli-extensions.containerapp # Azure Container Apps
      azure-cli-extensions.acssc        # Azure Container Storage

      # AI / OpenAI extensions
      azure-cli-extensions.azext_ai     # Azure AI Services
      azure-cli-extensions.cognitiveservices  # Cognitive Services

      # VM extensions
      azure-cli-extensions.vm           # Virtual Machines
      azure-cli-extensions.disk         # Managed Disks

      # Networking
      azure-cli-extensions.nsp          # Network Security Perimeter
    ];
  };
}
