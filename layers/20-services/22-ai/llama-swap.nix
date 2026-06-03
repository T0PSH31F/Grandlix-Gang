# llama-swap Proxy NixOS Service
# layers/20-services/22-ai/llama-swap.nix
{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.services.llama-swap-proxy;
in
{
  options.services.llama-swap-proxy = {
    enable = mkOption {
      type = types.bool;
      default = config.services.llama-cpp-server.enable or false;
      description = "Whether to enable llama-swap Proxy service";
    };

    port = mkOption {
      type = types.port;
      default = 8085;
      description = "Port to listen on";
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = "Structured settings for llama-swap (e.g. server, models, groups)";
    };
  };

  config = mkIf cfg.enable {
    # 1. Native NixOS llama-swap service
    services.llama-swap = {
      enable = true;
      port = cfg.port;
      settings = cfg.settings;
    };

    # 2. Firewall
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
