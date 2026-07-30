{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.layers.layer-78.hermes-webui;
in
{
  imports = [
    inputs.hermes-webui.nixosModules.default
  ];

  options.layers.layer-78.hermes-webui = {
    enable = lib.mkEnableOption "Hermes WebUI — web interface for Hermes Agent";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8787;
      description = "Port for Hermes WebUI";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host to bind Hermes WebUI";
    };
  };

  config = lib.mkIf cfg.enable {
    services.hermes-webui = {
      enable = true;
      port = cfg.port;
      host = cfg.host;
    };
  };
}