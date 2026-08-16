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
      azure-cli-extensions.acrcssc     # Azure Container Registry CSSC
      azure-cli-extensions.acrquery    # Azure Container Registry Query
      azure-cli-extensions.aks-preview # Azure Kubernetes Service
      azure-cli-extensions.containerapp # Azure Container Apps

      # AI extensions
      azure-cli-extensions.ai-examples # Azure AI Examples
      azure-cli-extensions.arize-ai    # Arize AI observability

      # VM extensions
      azure-cli-extensions.vm-repair   # Virtual Machine Repair

      # Networking
      azure-cli-extensions.nsp         # Network Security Perimeter
    ];
  };
}
