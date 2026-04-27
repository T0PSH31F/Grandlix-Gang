{ lib, ... }: {
  features.services.config = {
    media-stack.enable = lib.mkDefault true;
  };
}
