# LiteLLM Proxy NixOS Service
{
  config,
  lib,
  ...
}:

with lib;
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
      default = "127.0.0.1";
      description = "Host address to bind to. Set to 127.0.0.1 to restrict access to localhost.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open ports in the firewall for LiteLLM. Note that external exposure also requires setting the host option to a non-loopback address.";
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = "Structured settings for LiteLLM";
    };
  };

  config =
    let
      cfg = config.services.litellm-proxy;
    in
    mkIf cfg.enable {
      services.litellm = {
        enable = true;
        inherit (cfg) port;
        inherit (cfg) host;
        inherit (cfg) settings;
      };

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
    };
}
