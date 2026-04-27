# flake-parts/system/resource-limits.nix
# Purpose:
# - Stabilize system by capping background service resources
# - Prevent memory starvation (OOM/Thrashing)
# - Ensure interactive session (Hyprland/Editor) remains responsive

{
  config,
  lib,
  ...
}:

let
  cfg = config.features.system.config.resource-limits;
in
{
  options.features.system.config.resource-limits = {
    enable = lib.mkEnableOption "System-wide resource limits for background services";
  };

  config = lib.mkIf cfg.enable {
    # Define a background slice for all non-interactive services
    systemd.slices.background = {
      description = "Background Services Slice";
      sliceConfig = {
        CPUWeight = 20; # Lower priority (Default is 100)
        IOWeight = 20;
        # Prevent background services from eating all memory
        MemoryHigh = "8G";
        MemoryMax = "10G";
      };
    };

    # Apply slice and individual limits to known heavy services
    systemd.services = {
      # Matrix Synapse - Notoriously memory hungry
      matrix-synapse = {
        serviceConfig = {
          Slice = lib.mkForce "background.slice";
          MemoryHigh = "2G";
          MemoryMax = "3G";
        };
      };

      # n8n - NodeJS based automation
      n8n = {
        serviceConfig = {
          Slice = lib.mkForce "background.slice";
          MemoryHigh = "1G";
          MemoryMax = "2G";
        };
      };

      # Immich - Photo/Video indexing
      immich-server = {
        serviceConfig = {
          Slice = lib.mkForce "background.slice";
          MemoryHigh = "2G";
          MemoryMax = "3G";
        };
      };

      # Calibre-Web
      calibre-web = {
        serviceConfig = {
          Slice = lib.mkForce "background.slice";
          MemoryHigh = "512M";
          MemoryMax = "1G";
        };
      };

      # AI Services (Common ones)
      chromadb = {
        serviceConfig = {
          Slice = lib.mkForce "background.slice";
          MemoryHigh = "1G";
          MemoryMax = "2G";
        };
      };

      localai = {
        serviceConfig = {
          Slice = lib.mkForce "background.slice";
          MemoryHigh = "4G";
          MemoryMax = "6G";
        };
      };

      # Loki / Promtail / Prometheus
      loki = {
        serviceConfig = {
          Slice = lib.mkForce "background.slice";
          MemoryHigh = "512M";
          MemoryMax = "1G";
        };
      };

      prometheus = {
        serviceConfig = {
          Slice = lib.mkForce "background.slice";
          MemoryHigh = "1G";
          MemoryMax = "2G";
        };
      };
    };
  };
}
