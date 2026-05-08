{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-20.services.config.usenet;
  mediaCfg = config.layers.layer-20.services.config.media-stack;
in
{
  options.layers.layer-20.services.config.usenet = {
    enable = mkEnableOption "Usenet clients (NZBGet, SABnzbd, NZBHydra2, Pan)";
    nzbget = {
      enable = mkEnableOption "NZBGet usenet client";
      port = mkOption { type = types.port; default = 6789; };
    };
    sabnzbd = {
      enable = mkEnableOption "SABnzbd usenet client";
      port = mkOption { type = types.port; default = 8081; }; # Using 8081 to avoid conflict with WebUI
    };
    nzbhydra2 = {
      enable = mkEnableOption "NZBHydra2 indexer";
      port = mkOption { type = types.port; default = 5076; };
    };
    pan.enable = mkEnableOption "Pan GUI newsreader";
  };

  config = mkIf cfg.enable {
    # ============================================================================
    # SABnzbd
    # ============================================================================
    services.sabnzbd = mkIf cfg.sabnzbd.enable {
      enable = true;
      user = mediaCfg.user;
      group = mediaCfg.group;
    };

    # Automatically set the port to 8081 if enabled to avoid 8080 collision
    systemd.services.sabnzbd = mkIf cfg.sabnzbd.enable {
      serviceConfig.ExecStart = mkForce "${pkgs.sabnzbd}/bin/sabnzbd -f /var/lib/sabnzbd/sabnzbd.ini -s 0.0.0.0:${toString cfg.sabnzbd.port}";
    };

    # ============================================================================
    # NZBGET
    # ============================================================================
    services.nzbget = mkIf cfg.nzbget.enable {
      enable = true;
      user = mediaCfg.user;
      group = mediaCfg.group;
    };

    # ============================================================================
    # NZBHYDRA2
    # ============================================================================
    systemd.services.nzbhydra2 = mkIf cfg.nzbhydra2.enable {
      description = "NZBHydra2";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.nzbhydra2}/bin/nzbhydra2 --nobrowser --config /var/lib/nzbhydra2/nzbhydra.yml --database /var/lib/nzbhydra2/nzbhydra.db";
        User = mediaCfg.user;
        Group = mediaCfg.group;
        StateDirectory = "nzbhydra2";
        Restart = "on-failure";
      };
    };

    # ============================================================================
    # PAN GUI
    # ============================================================================
    environment.systemPackages = (optional cfg.pan.enable pkgs.pan);

    networking.firewall.allowedTCPPorts = 
      (optional cfg.nzbget.enable cfg.nzbget.port) ++
      (optional cfg.sabnzbd.enable cfg.sabnzbd.port) ++
      (optional cfg.nzbhydra2.enable cfg.nzbhydra2.port);

    environment.persistence."/persist" = mkIf config.layers.layer-10.system.config.impermanence.enable {
      directories = 
        (optional cfg.nzbget.enable {
          directory = "/var/lib/nzbget";
          user = mediaCfg.user;
          group = mediaCfg.group;
          mode = "0750";
        }) ++
        (optional cfg.sabnzbd.enable {
          directory = "/var/lib/sabnzbd";
          user = mediaCfg.user;
          group = mediaCfg.group;
          mode = "0750";
        }) ++
        (optional cfg.nzbhydra2.enable {
          directory = "/var/lib/nzbhydra2";
          user = mediaCfg.user;
          group = mediaCfg.group;
          mode = "0750";
        });
    };
  };
}
