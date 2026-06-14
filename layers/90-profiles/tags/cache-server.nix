{ lib, ... }:
{
  services.harmonia.cache.enable = lib.mkDefault true;
}
