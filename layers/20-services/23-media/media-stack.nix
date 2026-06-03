{
  config,
  lib,
  ...
}:
with lib;
{
  options.layers.layer-20.services.config.media-stack = {
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
      default = "/home/t0psh31f/media/downloads";
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

  config = mkIf config.layers.layer-20.services.config.media-stack.enable {
    # Enable download clients subsystem and default to aria2
    layers.layer-20.services.config.download-clients = {
      enable = mkDefault true;
      aria2.enable = mkDefault true;
    };

    # Enable Usenet & Recyclarr by default with media-stack
    layers.layer-20.services.config.usenet = {
      enable = mkDefault false;
      sabnzbd.enable = mkDefault true;
      nzbget.enable = mkDefault true;
      nzbhydra2.enable = mkDefault true;
    };

    layers.layer-20.services.config.recyclarr.enable = mkDefault true;

    # ============================================================================
    # USER & GROUP
    # ============================================================================
    users.users.${config.layers.layer-20.services.config.media-stack.user} = {
      isSystemUser = true;
      group = config.layers.layer-20.services.config.media-stack.group;
      home = config.layers.layer-20.services.config.media-stack.dataDir;

      createHome = true;
      extraGroups = [
        "video"
        "render"
      ]; # For hardware transcoding
    };

    users.groups.${config.layers.layer-20.services.config.media-stack.group} = { };

    # ============================================================================
    # DIRECTORY STRUCTURE
    # ============================================================================
    systemd.tmpfiles.rules = [
      "d ${config.layers.layer-20.services.config.media-stack.dataDir} 0755 ${config.layers.layer-20.services.config.media-stack.user} ${config.layers.layer-20.services.config.media-stack.group} -"
      "d ${config.layers.layer-20.services.config.media-stack.downloadsDir} 0755 ${config.layers.layer-20.services.config.media-stack.user} ${config.layers.layer-20.services.config.media-stack.group} -"
      "d /var/lib/jellyfin 0750 ${config.layers.layer-20.services.config.media-stack.user} ${config.layers.layer-20.services.config.media-stack.group} -"
      "d /var/lib/jellyfin/log 0750 ${config.layers.layer-20.services.config.media-stack.user} ${config.layers.layer-20.services.config.media-stack.group} -"
      "d ${config.layers.layer-20.services.config.media-stack.dataDir}/tv 0755 ${config.layers.layer-20.services.config.media-stack.user} ${config.layers.layer-20.services.config.media-stack.group} -"
      "d ${config.layers.layer-20.services.config.media-stack.dataDir}/movies 0755 ${config.layers.layer-20.services.config.media-stack.user} ${config.layers.layer-20.services.config.media-stack.group} -"
      "d ${config.layers.layer-20.services.config.media-stack.dataDir}/music 0755 ${config.layers.layer-20.services.config.media-stack.user} ${config.layers.layer-20.services.config.media-stack.group} -"
      "d ${config.layers.layer-20.services.config.media-stack.dataDir}/books 0755 ${config.layers.layer-20.services.config.media-stack.user} ${config.layers.layer-20.services.config.media-stack.group} -"
      "d ${config.layers.layer-20.services.config.media-stack.dataDir}/torrents 0755 ${config.layers.layer-20.services.config.media-stack.user} ${config.layers.layer-20.services.config.media-stack.group} -"
      # Fix Prowlarr state directory ownership
      "d /var/lib/prowlarr 0750 ${config.layers.layer-20.services.config.media-stack.user} ${config.layers.layer-20.services.config.media-stack.group} -"
      "d /var/lib/sonarr 0750 ${config.layers.layer-20.services.config.media-stack.user} ${config.layers.layer-20.services.config.media-stack.group} -"
      "d /var/lib/radarr 0750 ${config.layers.layer-20.services.config.media-stack.user} ${config.layers.layer-20.services.config.media-stack.group} -"
      "d /var/lib/lidarr 0750 ${config.layers.layer-20.services.config.media-stack.user} ${config.layers.layer-20.services.config.media-stack.group} -"
      "d /var/lib/readarr 0750 ${config.layers.layer-20.services.config.media-stack.user} ${config.layers.layer-20.services.config.media-stack.group} -"
      "d /var/lib/bazarr 0750 ${config.layers.layer-20.services.config.media-stack.user} ${config.layers.layer-20.services.config.media-stack.group} -"
    ];



    # ============================================================================
    # JELLYFIN - Media Server
    # ============================================================================
    services.jellyfin =
      mkIf
        (config.layers.layer-20.services.config.media-stack.enable && config.layers.layer-20.services.config.media-stack.enableJellyfin)
        {
          enable = true;
          user = config.layers.layer-20.services.config.media-stack.user;
          group = config.layers.layer-20.services.config.media-stack.group;
          openFirewall = true;
        };

    # ============================================================================
    # SONARR - TV Shows
    # ============================================================================
    services.sonarr = {
      enable = true;
      user = config.layers.layer-20.services.config.media-stack.user;
      group = config.layers.layer-20.services.config.media-stack.group;
    };

    # ============================================================================
    # RADARR - Movies
    # ============================================================================
    services.radarr = {
      enable = true;
      user = config.layers.layer-20.services.config.media-stack.user;
      group = config.layers.layer-20.services.config.media-stack.group;
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
        DynamicUser = lib.mkForce false;
        User = lib.mkForce config.layers.layer-20.services.config.media-stack.user;
        Group = lib.mkForce config.layers.layer-20.services.config.media-stack.group;
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

    environment.persistence."/persist" = mkIf config.layers.layer-10.system.config.impermanence.enable {

      directories = [

        config.layers.layer-20.services.config.media-stack.dataDir

        config.layers.layer-20.services.config.media-stack.downloadsDir

        {
          directory = "/var/lib/jellyfin";
          user = config.layers.layer-20.services.config.media-stack.user;
          group = config.layers.layer-20.services.config.media-stack.group;
          mode = "0750";
        }

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
