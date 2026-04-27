{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.features.services.config.media-stack = {
    enable = mkEnableOption "Complete media management stack (Homarr, Deluge, aria2, *arr suite)";

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/media";
      description = "Base directory for media storage";
    };

    enableJellyfin = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Jellyfin media server";
    };

    downloadsDir = mkOption {
      type = types.str;
      default = "/var/lib/media/downloads";
      description = "Downloads directory";
    };

    user = mkOption {
      type = types.str;
      default = "media";
      description = "User for media services";
    };

    group = mkOption {
      type = types.str;
      default = "media";
      description = "Group for media services";
    };
  };

  config = mkIf config.features.services.config.media-stack.enable {
    # ============================================================================
    # USER & GROUP
    # ============================================================================
    users.users.${config.features.services.config.media-stack.user} = {
      isSystemUser = true;
      group = config.features.services.config.media-stack.group;
      home = config.features.services.config.media-stack.dataDir;

      createHome = true;
      extraGroups = [
        "video"
        "render"
      ]; # For hardware transcoding
    };

    users.groups.${config.features.services.config.media-stack.group} = { };

    # ============================================================================
    # DIRECTORY STRUCTURE
    # ============================================================================
    systemd.tmpfiles.rules = [
      "d ${config.features.services.config.media-stack.dataDir} 0755 ${config.features.services.config.media-stack.user} ${config.features.services.config.media-stack.group} -"
      "d ${config.features.services.config.media-stack.downloadsDir} 0755 ${config.features.services.config.media-stack.user} ${config.features.services.config.media-stack.group} -"
      "d ${config.features.services.config.media-stack.dataDir}/tv 0755 ${config.features.services.config.media-stack.user} ${config.features.services.config.media-stack.group} -"
      "d ${config.features.services.config.media-stack.dataDir}/movies 0755 ${config.features.services.config.media-stack.user} ${config.features.services.config.media-stack.group} -"
      "d ${config.features.services.config.media-stack.dataDir}/music 0755 ${config.features.services.config.media-stack.user} ${config.features.services.config.media-stack.group} -"
      "d ${config.features.services.config.media-stack.dataDir}/books 0755 ${config.features.services.config.media-stack.user} ${config.features.services.config.media-stack.group} -"
      "d ${config.features.services.config.media-stack.dataDir}/torrents 0755 ${config.features.services.config.media-stack.user} ${config.features.services.config.media-stack.group} -"
      # Fix Prowlarr state directory ownership
      "d /var/lib/prowlarr 0750 ${config.features.services.config.media-stack.user} ${config.features.services.config.media-stack.group} -"
      "d /var/lib/sonarr 0750 ${config.features.services.config.media-stack.user} ${config.features.services.config.media-stack.group} -"
      "d /var/lib/radarr 0750 ${config.features.services.config.media-stack.user} ${config.features.services.config.media-stack.group} -"
      "d /var/lib/lidarr 0750 ${config.features.services.config.media-stack.user} ${config.features.services.config.media-stack.group} -"
      "d /var/lib/readarr 0750 ${config.features.services.config.media-stack.user} ${config.features.services.config.media-stack.group} -"
      "d /var/lib/bazarr 0750 ${config.features.services.config.media-stack.user} ${config.features.services.config.media-stack.group} -"
      "d /var/lib/deluge 0750 ${config.features.services.config.media-stack.user} ${config.features.services.config.media-stack.group} -"
    ];

    # ============================================================================
    # DELUGE - Torrent Client
    # ============================================================================
    services.deluge = {
      enable = true;
      web.enable = true;
      web.port = 8112;

      # Deluge daemon settings
      declarative = true;
      authFile = pkgs.writeText "deluge-auth" "localclient:a7b8c9d0e1f2:10";
      config = {
        download_location = "${config.features.services.config.media-stack.downloadsDir}/torrents";
        max_active_downloading = 5;
        max_active_seeding = 10;
        max_active_limit = 15;

        # Network settings
        random_port = false;
        listen_ports = [
          6881
          6889
        ];

        # Encryption
        enc_prefer_rc4 = true;
        enc_level = 1; # Prefer encryption
      };

      # Override user/group
      user = config.features.services.config.media-stack.user;
      group = config.features.services.config.media-stack.group;
    };

    # ============================================================================
    # JELLYFIN - Media Server
    # ============================================================================
    services.jellyfin =
      mkIf
        (config.features.services.config.media-stack.enable && config.features.services.config.media-stack.enableJellyfin)
        {
          enable = true;
          user = config.features.services.config.media-stack.user;
          group = config.features.services.config.media-stack.group;
          openFirewall = true;
        };

    # ============================================================================
    # SONARR - TV Shows
    # ============================================================================
    services.sonarr = {
      enable = true;
      user = config.features.services.config.media-stack.user;
      group = config.features.services.config.media-stack.group;
    };

    # ============================================================================
    # RADARR - Movies
    # ============================================================================
    services.radarr = {
      enable = true;
      user = config.features.services.config.media-stack.user;
      group = config.features.services.config.media-stack.group;
    };

    # ============================================================================
    # PROWLARR - Indexer Manager
    # ============================================================================
    services.prowlarr = {
      enable = true;
    };

    # Fix Prowlarr state directory ownership and permissions
    systemd.services.prowlarr = {
      serviceConfig = {
        User = lib.mkForce config.features.services.config.media-stack.user;
        Group = lib.mkForce config.features.services.config.media-stack.group;
        StateDirectory = lib.mkForce "prowlarr";
        StateDirectoryMode = lib.mkForce "0750";
        # Fix NAMESPACE issue with impermanence
        PrivateTmp = lib.mkForce false;
        ProtectSystem = lib.mkForce false;
        ProtectHome = lib.mkForce false;
        ReadWritePaths = [ "/var/lib/prowlarr" ];
      };
    };

    # Ensure data is persisted

    environment.persistence."/persist" = mkIf config.features.system.config.impermanence.enable {

      directories = [

        config.features.services.config.media-stack.dataDir

        config.features.services.config.media-stack.downloadsDir

        "/var/lib/jellyfin"

        "/var/lib/sonarr"

        "/var/lib/radarr"

        "/var/lib/prowlarr"

        "/var/lib/lidarr"

        "/var/lib/readarr"

        "/var/lib/bazarr"

      ];

    };

  };
}
