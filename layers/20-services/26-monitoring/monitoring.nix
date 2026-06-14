{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.layers.layer-20.services.config.monitoring = {
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
      default = 3008;
      description = "Grafana port";
    };
  };

  config = mkIf config.layers.layer-20.services.config.monitoring.enable {
    clan.core.vars.generators.grafana = {
      files."admin-password" = {
        secret = true;
        owner = "grafana";
        group = "grafana";
      };
      files."secret-key" = {
        secret = true;
        owner = "grafana";
        group = "grafana";
      };
      script = ''
        ${pkgs.openssl}/bin/openssl rand -base64 18 | tr -d '\n' > "$out/admin-password"
        ${pkgs.openssl}/bin/openssl rand -hex 24 | tr -d '\n' > "$out/secret-key"
      '';
    };

    # ============================================================================
    # PROMETHEUS - Metrics Collection
    # ============================================================================
    services.prometheus = {
      enable = true;
      port = config.layers.layer-20.services.config.monitoring.prometheus.port;

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
              targets = [
                "localhost:${toString config.layers.layer-20.services.config.monitoring.prometheus.port}"
              ];
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
              targets = [ "localhost:${toString config.layers.layer-20.services.config.monitoring.loki.port}" ];
            }
          ];
        }

        # Grafana
        {
          job_name = "grafana";
          static_configs = [
            {
              targets = [
                "localhost:${toString config.layers.layer-20.services.config.monitoring.grafana.port}"
              ];
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
        server.http_listen_port = config.layers.layer-20.services.config.monitoring.loki.port;

        auth_enabled = false;

        common = {
          ring = {
            instance_interface_names = [
              "lo"
              "wlp0s20f3"
              "tailscale0"
            ];
            kvstore.store = "inmemory";
          };
        };

        memberlist = {
          bind_addr = [ "127.0.0.1" ];
        };

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
          http_port = config.layers.layer-20.services.config.monitoring.grafana.port;
          domain = config.layers.layer-20.services.config.monitoring.domain;
          root_url = "http://%(domain)s:%(http_port)s/";
        };
        security = {
          admin_password = "$__file{${config.clan.core.vars.generators.grafana.files."admin-password".path}}";
          secret_key = "$__file{${config.clan.core.vars.generators.grafana.files."secret-key".path}}";
        };
      };
    };

    # Ensure data is persisted
    environment.persistence."/persist" = mkIf config.layers.layer-10.system.config.impermanence.enable {
      directories = [
        "/var/lib/prometheus"
        "/var/lib/loki"
        "/var/lib/grafana"
      ];
    };
  };
}
