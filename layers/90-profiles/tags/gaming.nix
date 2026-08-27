# gaming — Steam, GameMode, emulators
# Tags-as-data: all config gated by tag membership.
{ config, lib, ... }:
{
  config = lib.mkIf (builtins.elem "gaming" config.machine.tags) {
    layers.layer-60.gui.gaming.enable = lib.mkDefault true;
  };
}
