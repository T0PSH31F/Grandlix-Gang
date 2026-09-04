# ai-router — LLM routing and gateway services
# Deployed on always-on control-plane machines that route agent LLM requests.
# Does NOT run inference — delegates to ExtremeRouter (z0r0) or cloud providers.
{ config, lib, ... }:
{
  config = lib.mkIf (lib.elem "ai-router" config.machine.tags) {
    services.ai-services = {
      kong-gateway.enable = lib.mkDefault true;
      omniroute.enable = lib.mkDefault true;
      freellmapi.enable = lib.mkDefault true;
      freellmpool.enable = lib.mkDefault true;
      postgresql.enable = lib.mkDefault true;
    };
  };
}
