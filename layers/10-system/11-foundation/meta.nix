{ lib, ... }:
{
  options.layers.meta = {
    primaryUser = lib.mkOption {
      type = lib.types.str;
      default = "t0psh31f";
      description = "Primary user for home-manager integration";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "lovelain.duckdns.org";
      description = "Primary DNS domain for service routing";
    };
    fleetNetwork = lib.mkOption {
      type = lib.types.str;
      default = "100.0.0.0/8";
      description = "Internal fleet network CIDR (Tailscale)";
    };
  };
}
