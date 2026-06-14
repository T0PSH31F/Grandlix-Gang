{ lib, ... }:
{
  layers.layer-20.services.config = {
    media-stack.enable = lib.mkDefault true;
  };
}
