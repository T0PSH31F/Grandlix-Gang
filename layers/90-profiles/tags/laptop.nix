# laptop — battery optimizations and wireless tools
# Tags-as-data: all config gated by tag membership.
# Note: laptop-specific hardware config is in layers/10-system/12-processor/12.4-platform/laptop.nix
# which auto-detects the "laptop" tag.
{ config, lib, ... }:
{
  config = lib.mkIf (builtins.elem "laptop" config.machine.tags) {
    # Laptop-specific hardware config auto-detects via tag in
    # layers/10-system/12-processor/12.4-platform/laptop.nix
  };
}
