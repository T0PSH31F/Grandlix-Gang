{
  config,
  lib,
  ...
}:
with lib;
{
  options.features.services.config.monitoring = {
    enable = mkEnableOption "Comprehensive monitoring stack with Prometheus, Loki, and Grafana";

    domain = mkOption {
      type = types.str;
      default = "localhost";
      description = "Domain for Grafana access";
    };

    prometheus.port = mkOption {
      type = types.port;
      default = 9090;
      description = "Prometheus port";
    };

    loki.port = mkOption {
      type = types.port;
      default = 3100;
      description = "Loki port";
    };

    grafana.port = mkOption {
      type = types.port;
      default = 3000;
      description = "Grafana port";
    };
  };

  config = mkIf config.features.services.config.monitoring.enable {
    sops.secrets.grafana_pass = {
      sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml;
    };

    # ============================================================================
    # PROMETHEUS - Metrics Collection
    # ============================================================================
    services.prometheus = {
      enable = true;
      port = config.features.services.config.monitoring.prometheus.port;

      # Retention (default 15 days)
      retentionTime = "30d";

      # Exporters for system metrics
      exporters = {
        node = {
          enable = true;
          port = 9100;
          enabledCollectors = [
            "systemd"
            "cpu"
            "diskstats"
            "filesystem"
            "loadavg"
            "meminfo"
            "netdev"
            "processes"
          ];
        };
      };

      # Scrape configurations
      scrapeConfigs = [
        # Prometheus itself
        {
          job_name = "prometheus";
          static_configs = [
            {
              targets = [ "localhost:${toString config.features.services.config.monitoring.prometheus.port}" ];
            }
          ];
        }

        # Node exporter (system metrics)
        {
          job_name = "node";
          static_configs = [
            {
              targets = [ "localhost:9100" ];
            }
          ];
        }

        # Loki
        {
          job_name = "loki";
          static_configs = [
            {
              targets = [ "localhost:${toString config.features.services.config.monitoring.loki.port}" ];
            }
          ];
        }

        # Grafana
        {
          job_name = "grafana";
          static_configs = [
            {
              targets = [ "localhost:${toString config.features.services.config.monitoring.grafana.port}" ];
            }
          ];
        }
      ];
    };

    # ============================================================================
    # LOKI - Log Aggregation
    # ============================================================================
    services.loki = {
      enable = true;

      configuration = {
        server.http_listen_port = config.features.services.config.monitoring.loki.port;

        auth_enabled = false;

        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring = {
              kvstore.store = "inmemory";
              replication_factor = 1;
            };
          };
          chunk_idle_period = "1h";
          max_chunk_age = "1h";
          chunk_target_size = 999999;
          chunk_retain_period = "30s";
        };

        schema_config = {
          configs = [
            {
              from = "2024-01-01";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };

        storage_config = {
          tsdb_shipper = {
            active_index_directory = "/var/lib/loki/tsdb-index";
            cache_location = "/var/lib/loki/tsdb-cache";
          };
          filesystem.directory = "/var/lib/loki/chunks";
        };

        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
          retention_period = "30d";
        };

        table_manager = {
          retention_deletes_enabled = true;
          retention_period = "30d";
        };

        compactor = {
          working_directory = "/var/lib/loki/compactor";
          compaction_interval = "10m";
          retention_enabled = true;
          retention_delete_delay = "2h";
          retention_delete_worker_count = 150;
          delete_request_store = "filesystem";
        };
      };
    };

    # ============================================================================
    # GRAFANA - Visualization
    # ============================================================================
    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_port = config.features.services.config.monitoring.grafana.port;
          domain = config.features.services.config.monitoring.domain;
          root_url = "http://%(domain)s:%(http_port)s/";
        };
        security = {
          admin_password = "$__file{${config.sops.secrets.grafana_pass.path}}";
          # Required for NixOS 26.05+
          # Using the legacy default key as recommended for non-breaking migration
          secret_key = "SW2YcwTIb9zpOOhoPsMm";
        };
      };
    };

    # Ensure data is persisted
    environment.persistence."/persist" = mkIf config.features.system.config.impermanence.enable {
      directories = [
        "/var/lib/prometheus"
        "/var/lib/loki"
        "/var/lib/grafana"
      ];
    };
  };
}
