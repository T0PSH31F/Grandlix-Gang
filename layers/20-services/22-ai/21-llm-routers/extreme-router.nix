# Deprecated: services.ai-services.extreme-router is aliased to layers.layer-20.services.extreme-router (removal in 2 releases, v26.11).
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-20.services.extreme-router;
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "ai-services" "extreme-router" "enable" ]
      [ "layers" "layer-20" "services" "extreme-router" "enable" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "ai-services" "extreme-router" "port" ]
      [ "layers" "layer-20" "services" "extreme-router" "port" ]
    )
  ];

  options.layers.layer-20.services.extreme-router = {
    enable = mkEnableOption "ExtremeRouter — AI gateway with 154+ providers and RTK token savings";

    port = mkOption {
      type = types.port;
      default = 20128;
      description = "ExtremeRouter web UI and API port";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/extreme-router";
      description = "Persistent data directory for ExtremeRouter";
    };

    image = mkOption {
      type = types.str;
      default = "docker.io/rsalmn/extremerouter@sha256:b710a8164939b64aebbbc3bff863a361e10367dd7b556f5159e0d81fe6b2fb3f";
      description = "Docker image for ExtremeRouter";
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Environment file for ExtremeRouter secrets (JWT_SECRET, etc.)";
    };

    extraEnvironment = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Extra environment variables for ExtremeRouter";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion =
          !(config.fileSystems."/" ? fsType && config.fileSystems."/".fsType == "tmpfs")
          || (config.layers.layer-10.system.config.impermanence.enable or false);
        message = "services.ai-services.extreme-router requires impermanence to be enabled (config.layers.layer-10.system.config.impermanence.enable = true) on machines with tmpfs root to prevent API key loss on reboot.";
      }
    ];

    # Create data directory with open permissions for container user
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0777 root root -"
    ];

    # OCI container via podman
    virtualisation.oci-containers.containers.extreme-router = {
      inherit (cfg) image;
      ports = [
        "127.0.0.1:${toString cfg.port}:20128"
      ];
      environment = {
        NODE_ENV = "production";
        PORT = "20128";
        HOSTNAME = "0.0.0.0";
        DATA_DIR = "/app/data";
        NEXT_PUBLIC_BASE_URL = "http://localhost:${toString cfg.port}";
      }
      // cfg.extraEnvironment;
      volumes = [
        "${cfg.dataDir}:/app/data"
      ];
      environmentFiles = optional (cfg.environmentFile != null) cfg.environmentFile;
      extraOptions = [
        "--user=root"
        "--health-cmd=node -e \"fetch('http://127.0.0.1:20128/api/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))\""
        "--health-interval=30s"
        "--health-timeout=5s"
        "--health-start-period=60s"
        "--health-retries=3"
        "--memory=1g"
        "--pids-limit=512"
        "--security-opt=no-new-privileges:true"
      ];
      autoStart = true;
    };

    # Open firewall port
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    # Impermanence persistence support
    environment.persistence."/persist" =
      mkIf (config.layers.layer-10.system.config.impermanence.enable or false)
        {
          directories = [
            {
              directory = cfg.dataDir;
              user = "root";
              group = "root";
              mode = "0777";
            }
          ];
        };
  };
}
