# cache-server — Harmonia Nix binary cache
# Tags-as-data: all config gated by tag membership.
{ config, lib, ... }:
{
  config = lib.mkIf (builtins.elem "cache-server" config.machine.tags) {
    services.harmonia.cache.enable = lib.mkDefault true;
  };
}
