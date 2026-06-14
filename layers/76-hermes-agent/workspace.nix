{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.layers.layer-76.hermes.workspace;
in
{
  options.layers.layer-76.hermes.workspace = {
    enable = lib.mkEnableOption "Hermes Workspace — AI agent command center";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3001;
      description = "Port for the workspace UI (3001 to avoid conflict with homepage)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Import the upstream module from the flake input
    imports = [
      inputs.hermes-workspace.nixosModules.hermes-workspace
    ];

    services.hermes-workspace = {
      enable = true;
      port = cfg.port;
      # Link to the local hermes-agent gateway (default is 8642, but check our config)
      hermesApiUrl = "http://127.0.0.1:8642";
      # Open firewall if needed (already handled by service module usually, but we check)
    };

    # Ensure data directory is persisted
    layers.layer-10.system.config.impermanence.persistPath = lib.mkIf config.layers.layer-10.system.config.impermanence.enable "/persist";
    # We already have .hermes in impermanence.nix, but hermes-workspace might use /var/lib/hermes-workspace
  };
}
