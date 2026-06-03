{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-20.services.config.recyclarr;
  mediaCfg = config.layers.layer-20.services.config.media-stack;
in
{
  options.layers.layer-20.services.config.recyclarr = {
    enable = mkEnableOption "Recyclarr (TRaSH Guides sync for Sonarr/Radarr)";
  };

  config = mkIf cfg.enable {
    # NixOS doesn't have a background daemon for recyclarr, it's a CLI tool.
    # But it does provide a systemd timer `services.recyclarr.enable` if available.
    # We will just enable the package so the user can initialize it and run it manually
    # or set up the native module if it exists.
    
    environment.systemPackages = [ pkgs.recyclarr ];

    # Attempt to enable the native service if present in the current nixpkgs tree
    services.recyclarr = mkIf (hasAttr "recyclarr" config.services) {
      enable = true;
      configuration = {
        sonarr = {
          tv = {
            base_url = "http://localhost:8989";
            # Uses NixOS's genJqSecretsReplacement for secret injection
            api_key = { _secret = "/var/lib/recyclarr/sonarr_api_key"; };
            
            # Rock-solid TRaSH Guides setup for Sonarr (WEB-1080p focus)
            include = [
              { template = "sonarr-quality-definition-series"; }
              { template = "sonarr-v4-quality-profile-web-1080p"; }
              { template = "sonarr-v4-custom-formats-web-1080p"; }
            ];
            
            # Optional: Overrides and granular Media Management settings
            media_management = {
              episode_naming = "{Series TitleYear} - S{season:00}E{episode:00} - {Episode Title} [{Custom_Formats }{Quality Full}]{[MediaInfo VideoDynamicRangeType]}{[MediaInfo VideoBitDepth]bit}{[MediaInfo VideoCodec]}[{Mediainfo AudioCodec} { Mediainfo AudioChannels}][{MediaGroup}]";
              season_folder_format = "Season {season:00}";
            };
          };
        };
        radarr = {
          movies = {
            base_url = "http://localhost:7878";
            api_key = { _secret = "/var/lib/recyclarr/radarr_api_key"; };
            
            # Rock-solid TRaSH Guides setup for Radarr (HD/Bluray/WEB 1080p focus)
            include = [
              { template = "radarr-quality-definition-movie"; }
              { template = "radarr-quality-profile-hd-bluray-web"; }
              { template = "radarr-custom-formats-hd-bluray-web"; }
            ];
            
            media_management = {
              movie_naming = "{Movie Title} ({Release Year}) {imdb-{ImdbId}}/{Movie Title} ({Release Year}) {imdb-{ImdbId}} - [{Custom_Formats }{Quality Full}]{[MediaInfo VideoDynamicRangeType]}{[MediaInfo VideoBitDepth]bit}{[MediaInfo VideoCodec]}[{Mediainfo AudioCodec} { Mediainfo AudioChannels}]{MediaGroup}";
            };
          };
        };
      };
    };

    environment.persistence."/persist" = mkIf config.layers.layer-10.system.config.impermanence.enable {
      directories = [
        {
          directory = "/var/lib/recyclarr";
          user = mediaCfg.user;
          group = mediaCfg.group;
          mode = "0750";
        }
      ];
    };
  };
}
