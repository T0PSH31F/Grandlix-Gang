# layers/20-services/22-ai/25-harness-control/everos.nix
# EverOS Memory Engine service (github.com/EverMind-AI/EverOS)
# Binds to localhost, indexes the canonical Markdown vault, provides memory retrieval API.

{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-20.services.everos;

  consolidationScript = pkgs.writeShellApplication {
    name = "everos-consolidation";
    runtimeInputs = [
      pkgs.curl
      pkgs.jq
    ];
    text = ''
      set -euo pipefail

      EVEROS_URL="http://127.0.0.1:${toString cfg.port}"
      echo "[everos-consolidation] Triggering nightly memory consolidation at $EVEROS_URL..."

      if curl -sf -X POST "$EVEROS_URL/api/v1/consolidate" >/dev/null 2>&1; then
        echo "[everos-consolidation] Nightly consolidation triggered successfully."
      else
        echo "[INFO] EverOS consolidation endpoint pinged (offline or self-indexing)."
      fi
    '';
  };
in
{
  options.layers.layer-20.services.everos = {
    enable = mkEnableOption "EverOS Memory Server";

    port = mkOption {
      type = types.port;
      default = 8092;
      description = "Port for EverOS localhost API binding";
    };

    vaultPath = mkOption {
      type = types.str;
      default = "/var/lib/memory/vault";
      description = "Path to the canonical markdown memory vault";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/everos";
      description = "Data directory for EverOS state and indexes";
    };

    consolidationSchedule = mkOption {
      type = types.str;
      default = "03:00";
      description = "Systemd timer schedule for nightly memory consolidation";
    };
  };

  config = mkIf cfg.enable {
    # Systemd tmpfiles rule for data directories
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0775 root memory -"
    ];

    # Impermanence persistence
    environment.persistence."/persist" =
      mkIf (config.layers.layer-10.system.config.impermanence.enable or false)
        {
          directories = [
            "/var/lib/everos"
          ];
        };

    environment.systemPackages = [
      consolidationScript
    ];

    # OCI container for EverOS
    virtualisation.oci-containers.containers.everos = {
      image = "ghcr.io/evermind-ai/everos:latest";
      ports = [ "127.0.0.1:${toString cfg.port}:8092" ];
      environment = {
        VAULT_PATH = cfg.vaultPath;
        DATA_DIR = cfg.dataDir;
        PORT = "8092";
        HOST = "127.0.0.1";
      };
      volumes = [
        "${cfg.vaultPath}:/var/lib/memory/vault"
        "${cfg.dataDir}:/var/lib/everos"
      ];
    };

    # Nightly consolidation service and timer
    systemd.services.everos-consolidation = {
      description = "Nightly EverOS Memory Consolidation";
      after = [ "podman-everos.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${consolidationScript}/bin/everos-consolidation";
        User = "root";
      };
    };

    systemd.timers.everos-consolidation = {
      description = "Timer for nightly EverOS memory consolidation";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.consolidationSchedule;
        Persistent = true;
      };
    };
  };
}
