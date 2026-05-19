# LiteLLM Proxy NixOS Service
# layers/20-services/22-ai/litellm.nix
{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.services.litellm-proxy;
in
{
  options.services.litellm-proxy = {
    enable = mkEnableOption "LiteLLM Proxy service";

    port = mkOption {
      type = types.port;
      default = 8084;
      description = "Port to listen on";
    };

    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Host address to bind to";
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = "Structured settings for LiteLLM";
    };
  };

  config = mkIf cfg.enable {
    # 1. Native NixOS LiteLLM service
    services.litellm = {
      enable = true;
      port = cfg.port;
      host = cfg.host;
      settings = cfg.settings;
    };

    # 2. Firewall
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
