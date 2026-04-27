# Your Spotify - Spotify listening history analytics
# layers/nixos/services/your-spotify.nix
{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.features.services.config.your-spotify;
in
{
  options.features.services.config.your-spotify = {
    enable = mkEnableOption "Your Spotify analytics service";

    port = mkOption {
      type = types.port;
      default = 3456;
      description = "API server port";
    };

    clientEndpoint = mkOption {
      type = types.str;
      default = "http://localhost:3457";
      description = "Client endpoint URL";
    };

    apiEndpoint = mkOption {
      type = types.str;
      default = "http://localhost:3456";
      description = "API endpoint URL";
    };

    spotifyPublic = mkOption {
      type = types.str;
      default = "";
      description = "Spotify application public client ID";
    };

    spotifySecretFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to file containing Spotify application secret";
    };

    nginxVirtualHost = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Nginx virtual host for the client (optional)";
    };
  };

  config = mkIf cfg.enable {
    # Native NixOS Your Spotify service
    services.your_spotify = {
      enable = true;
      enableLocalDB = false; # Using containerized MongoDB to avoid source build

      settings = {
        PORT = cfg.port;
        API_ENDPOINT = cfg.apiEndpoint;
        CLIENT_ENDPOINT = cfg.clientEndpoint;
        SPOTIFY_PUBLIC = cfg.spotifyPublic;
        MONGO_ENDPOINT = "mongodb://localhost:27017/your_spotify";
      };

      spotifySecretFile = mkDefault (
        if cfg.spotifySecretFile != null then
          cfg.spotifySecretFile
        else
          "/var/lib/your_spotify/spotify_secret"
      );
      nginxVirtualHost = cfg.nginxVirtualHost;
    };

    # MongoDB Container (SSPL licensed, avoids local compilation)
    virtualisation.oci-containers.containers.your-spotify-db = {
      image = "mongodb:7.0";
      ports = [ "27017:27017" ];
      volumes = [
        "/var/lib/mongodb-container:/data/db"
      ];
    };

    # Firewall
    networking.firewall.allowedTCPPorts = [
      cfg.port
      3457
    ];

  };
}
