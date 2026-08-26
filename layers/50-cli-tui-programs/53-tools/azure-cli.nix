# Azure CLI with extensions for containers, AI, and VMs
{
  config,
  lib,
  pkgs,
  ...
}:

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

      # Extensions — add more as needed after verifying they build
      azure-cli-extensions.aks-preview # Azure Kubernetes Service
      azure-cli-extensions.nsp # Network Security Perimeter
    ];
  };
}
