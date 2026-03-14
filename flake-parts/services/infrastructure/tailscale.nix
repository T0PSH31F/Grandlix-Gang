{
  config,
  lib,
  ...
}:

{
  options.services-config.tailscale.enable = lib.mkEnableOption "Tailscale client";

  config = lib.mkIf config.services-config.tailscale.enable {
    # Shared Tailscale client configuration for the fleet connecting to Luffy's Headscale
    services.tailscale = {
      enable = true;
      # Tell clients to use your Headscale server
      extraUpFlags = [ "--login-server=https://headscale.lovelain.duckdns.org" ];
    };

    # Open UDP port 41641 for peer-to-peer Tailscale connections
    networking.firewall.allowedUDPPorts = [ 41641 ];
  };
}
