# layers/70-agents/74-ai-infra/agent-sandbox.nix
# OCI / Bubblewrap Agent Sandbox environment for isolated agent task execution.

{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-70.agent.sandbox;

  sandboxRunner = pkgs.writeShellApplication {
    name = "agent-sandbox-run";
    runtimeInputs = with pkgs; [
      podman
      bubblewrap
      coreutils
      jq
    ];
    text = ''
      set -euo pipefail

      BACKEND="${cfg.backend}"
      DATA_DIR="${cfg.dataDir}"

      mkdir -p "$DATA_DIR/workspaces" "$DATA_DIR/tmp"

      case "$BACKEND" in
        podman)
          echo "[agent-sandbox] Launching isolated container using Podman ($cfg.sandboxImage)..."
          exec podman run --rm -it \
            --name "agent-sandbox-$(date +%s)" \
            --read-only \
            --tmpfs /tmp:rw,noexec,nosuid,size=1g \
            --network "${if cfg.networkPolicy == "none" then "none" else "bridge"}" \
            -v "$DATA_DIR/workspaces:/workspace:rw" \
            "${cfg.sandboxImage}" "$@"
          ;;
        bubblewrap)
          echo "[agent-sandbox] Launching isolated environment using Bubblewrap..."
          exec bwrap \
            --ro-bind /usr /usr \
            --ro-bind /lib /lib \
            --ro-bind /lib64 /lib64 \
            --ro-bind /bin /bin \
            --ro-bind /sbin /sbin \
            --proc /proc \
            --dev /dev \
            --tmpfs /tmp \
            --bind "$DATA_DIR/workspaces" /workspace \
            --unshare-all \
            --share-net \
            -- "$@"
          ;;
        *)
          echo "Unsupported sandbox backend: $BACKEND"
          exit 1
          ;;
      esac
    '';
  };
in
{
  options.layers.layer-70.agent.sandbox = {
    enable = mkEnableOption "Agent Sandbox Environment";

    backend = mkOption {
      type = types.enum [
        "podman"
        "bubblewrap"
        "nspawn"
      ];
      default = "podman";
      description = "Isolation runtime backend for sandboxed agent tasks";
    };

    sandboxImage = mkOption {
      type = types.str;
      default = "docker.io/library/alpine:3.20";
      description = "OCI container image reference for agent sandbox executions";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/agent-sandbox";
      description = "Persistent state directory for sandboxed workspace data";
    };

    networkPolicy = mkOption {
      type = types.enum [
        "restricted"
        "none"
        "host"
      ];
      default = "restricted";
      description = "Network isolation policy for sandbox execution";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root -"
      "d ${cfg.dataDir}/workspaces 0755 root root -"
      "d ${cfg.dataDir}/tmp 0755 root root -"
    ];

    environment.persistence."/persist" =
      mkIf (config.layers.layer-10.system.config.impermanence.enable or false)
        {
          directories = [
            cfg.dataDir
          ];
        };

    environment.systemPackages = [
      sandboxRunner
    ];
  };
}
