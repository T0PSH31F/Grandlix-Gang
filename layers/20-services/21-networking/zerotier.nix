{ config, lib, ... }:
{
  # ZeroTier firewall configuration
  # The actual ZeroTier network is managed by Clan's built-in module
  # via inventory.instances.zerotier in clan.nix

  # Open ZeroTier port (always open - harmless if ZT not running)
  networking.firewall.allowedUDPPorts = [ 9993 ];

  # Trust ZeroTier interfaces (pattern matches zt* interfaces)
  networking.firewall.trustedInterfaces = [
    "zt0" # common ZeroTier interface name
    "ztnull" # null route interface
  ];
}
