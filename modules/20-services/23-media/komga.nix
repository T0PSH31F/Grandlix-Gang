# Komga Comic/Manga Server
# modules/nixos/services/komga.nix
{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.services.komga-server;
in
{
  options.services.komga-server = {
    enable = mkEnableOption "Komga comic/manga server";

    port = mkOption {
      type = types.port;
      default = 25600;
      description = "Web interface port";
    };

    libraryPath = mkOption {
      type = types.str;
      default = "/persist/data/media/comics";
      description = "Path to comic/manga library";
    };
  };

  config = mkIf cfg.enable {
    services.komga = {
      enable = true;
      openFirewall = true;
      settings = {
        server = {
          port = cfg.port;
        };
      };
    };

    # Impermanence support
    environment.persistence."/persist" = mkIf (config.system-config.impermanence.enable or false) {
      directories = [
        {
          directory = "/var/lib/komga";
          user = "komga";
          group = "komga";
          mode = "0700";
        }
      ];
    };
  };
}
