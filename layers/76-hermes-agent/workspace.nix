{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.layers.layer-76.hermes.workspace;
in
{
  imports = [
    inputs.hermes-workspace.nixosModules.hermes-workspace
  ];

  options.layers.layer-76.hermes.workspace = {
    enable = lib.mkEnableOption "Hermes Workspace — AI agent command center";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3001;
      description = "Port for the workspace UI (3001 to avoid conflict with homepage)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.hermes-workspace = {
      enable = true;
      port = cfg.port;
      hermesApiUrl = "http://127.0.0.1:8642";
    };
  };
}
