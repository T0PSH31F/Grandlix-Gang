{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-20.services.communication.camofox-browser;
  camofoxPkg = pkgs.camofox-browser;
in
{
  options.layers.layer-20.services.communication.camofox-browser = {
    enable = mkEnableOption "Camofox anti-detection browser server";
    port = mkOption {
      type = types.port;
      default = 9377;
      description = "Port for the Camofox browser server";
    };
    apiKey = mkOption {
      type = types.str;
      default = "";
      description = "API key for cookie import endpoint";
    };
    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/camofox";
      description = "Data directory for Camofox profiles and cookies";
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open the Camofox port in the firewall";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ camofoxPkg ];

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 camofox camofox -"
    ];

    users.users.camofox = {
      isSystemUser = true;
      group = "camofox";
      home = cfg.dataDir;
      createHome = true;
    };
    users.groups.camofox = {};

    systemd.services.camofox-browser = {
      description = "Camofox anti-detection browser server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = "camofox";
        Group = "camofox";
        ExecStart = "${camofoxPkg}/bin/camofox-server";
        Restart = "on-failure";
        RestartSec = 5;
        StateDirectory = "camofox";
        StateDirectoryMode = "0755";
        Environment = [
          "CAMOFOX_PORT=${toString cfg.port}"
          "CAMOFOX_DATA_DIR=${cfg.dataDir}"
          "CAMOFOX_PROFILE_DIR=${cfg.dataDir}/profiles"
          "CAMOFOX_COOKIES_DIR=${cfg.dataDir}/cookies"
          "BROWSER_IDLE_TIMEOUT_MS=300000"
          "MAX_SESSIONS=50"
          "CAMOFOX_CRASH_REPORT_ENABLED=false"
        ] ++ lib.optional (cfg.apiKey != "") "CAMOFOX_API_KEY=${cfg.apiKey}";
      };
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
  };
}
