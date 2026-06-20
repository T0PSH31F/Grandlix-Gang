{
  config,
  lib,
  ...
}:
with lib;
{
  config = mkIf config.layers.layer-20.services.config.media-stack.enable {
    services.jellyfin = mkIf config.layers.layer-20.services.config.media-stack.enableJellyfin {
      enable = true;
      user = config.layers.layer-20.services.config.media-stack.user;
      group = config.layers.layer-20.services.config.media-stack.group;
      openFirewall = true;
    };
  };
}
