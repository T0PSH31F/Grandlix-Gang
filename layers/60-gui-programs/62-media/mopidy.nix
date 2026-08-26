# Mopidy — Extensible music server
# https://mopidy.com
#
# Plays music from local disk, Spotify, SoundCloud, Tidal, YouTube,
# and more. Supports MPD protocol, MPRIS, and web UI (Iris).
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-60.gui.mopidy;
in
{
  options.layers.layer-60.gui.mopidy = {
    enable = mkEnableOption "Mopidy — extensible music server";

    port = mkOption {
      type = types.port;
      default = 6680;
      description = "Port for Mopidy HTTP server";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/mopidy";
      description = "Data directory for Mopidy";
    };

    musicDir = mkOption {
      type = types.str;
      default = "/var/lib/mopidy/music";
      description = "Local music directory";
    };

    spotify = {
      enable = mkEnableOption "Spotify extension";
      clientId = mkOption {
        type = types.str;
        default = "";
        description = "Spotify client ID";
      };
      clientSecret = mkOption {
        type = types.str;
        default = "";
        description = "Spotify client secret";
      };
    };

    soundcloud = {
      enable = mkEnableOption "SoundCloud extension";
      authToken = mkOption {
        type = types.str;
        default = "";
        description = "SoundCloud auth token";
      };
    };

    tidal = {
      enable = mkEnableOption "Tidal extension";
    };

    youtube = {
      enable = mkEnableOption "YouTube extension";
    };

    ytmusic = {
      enable = mkEnableOption "YouTube Music extension";
    };

    podcast = {
      enable = mkEnableOption "Podcast extension";
    };

    jellyfin = {
      enable = mkEnableOption "Jellyfin extension";
      url = mkOption {
        type = types.str;
        default = "http://localhost:8096";
        description = "Jellyfin server URL";
      };
    };

    listenbrainz = {
      enable = mkEnableOption "ListenBrainz extension";
    };
  };

  config = mkIf cfg.enable {
    # Mopidy service
    systemd.services.mopidy = {
      description = "Mopidy music server";
      after = [
        "network.target"
        "sound.target"
      ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.mopidy}/bin/mopidy --config ${pkgs.writeText "mopidy.conf" ''
          [core]
          data_dir = ${cfg.dataDir}

          [http]
          enabled = true
          hostname = 0.0.0.0
          port = ${toString cfg.port}

          [mpd]
          enabled = true
          hostname = 0.0.0.0
          port = 6600

          [mpris]
          enabled = true

          [local]
          enabled = true
          media_dir = ${cfg.musicDir}

          [notify]
          enabled = true

          [iris]
          enabled = true
          country = US
          locale = en_US

          [audio]
          output = pulsesink server=127.0.0.1

          ${optionalString cfg.spotify.enable ''
            [spotify]
            enabled = true
            client_id = ${cfg.spotify.clientId}
            client_secret = ${cfg.spotify.clientSecret}
          ''}

          ${optionalString cfg.soundcloud.enable ''
            [soundcloud]
            enabled = true
            auth_token = ${cfg.soundcloud.authToken}
          ''}

          ${optionalString cfg.tidal.enable ''
            [tidal]
            enabled = true
          ''}

          ${optionalString cfg.youtube.enable ''
            [youtube]
            enabled = true
          ''}

          ${optionalString cfg.ytmusic.enable ''
            [ytmusic]
            enabled = true
          ''}

          ${optionalString cfg.podcast.enable ''
            [podcast]
            enabled = true
          ''}

          ${optionalString cfg.jellyfin.enable ''
            [jellyfin]
            enabled = true
            url = ${cfg.jellyfin.url}
          ''}

          ${optionalString cfg.listenbrainz.enable ''
            [listenbrainz]
            enabled = true
          ''}
        ''}";
        Restart = "always";
        RestartSec = 5;
        User = "mopidy";
        Group = "mopidy";
      };
    };

    # Create mopidy user
    users.users.mopidy = {
      isSystemUser = true;
      group = "mopidy";
      home = cfg.dataDir;
      createHome = true;
    };
    users.groups.mopidy = { };

    # Data directory
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 mopidy mopidy -"
      "d ${cfg.musicDir} 0755 mopidy mopidy -"
    ];

    # Open firewall ports
    networking.firewall.allowedTCPPorts = [
      cfg.port # HTTP API
      6600 # MPD protocol
    ];

    # Install extensions
    environment.systemPackages =
      with pkgs;
      [
        mopidy
        mopidy-iris
        mopidy-local
        mopidy-mpd
        mopidy-mpris
        mopidy-notify
        mopidy-podcast
        mopidy-argos
      ]
      ++ optionals cfg.spotify.enable [ pkgs.mopidy-spotify ]
      ++ optionals cfg.soundcloud.enable [ pkgs.mopidy-soundcloud ]
      ++ optionals cfg.tidal.enable [ pkgs.mopidy-tidal ]
      ++ optionals cfg.youtube.enable [ pkgs.mopidy-youtube ]
      ++ optionals cfg.jellyfin.enable [ pkgs.mopidy-jellyfin ]
      ++ optionals cfg.listenbrainz.enable [ pkgs.mopidy-listenbrainz ];
  };
}
