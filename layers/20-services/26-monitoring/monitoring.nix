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
      files."secret-key" = {
        secret = true;
        owner = "grafana";
        group = "grafana";
      };
      script = ''
        ${pkgs.openssl}/bin/openssl rand -hex 24 | tr -d '\n' > "$out/secret-key"
      '';
    };
    # Grafana admin password from sops
    sops.secrets.grafana_admin_password = {
      sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml;
      owner = "grafana";
      group = "grafana";
    };
    # ============================================================================
    # PROMETHEUS - Metrics Collection
    # ============================================================================
    services.prometheus = {
      enable = true;
      port = config.layers.layer-20.services.config.monitoring.prometheus.port;
      retentionTime = "30d";
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
        blackbox = {
          enable = true;
          configFile = pkgs.writeText "blackbox.yml" (
            builtins.toJSON {
              modules.http_2xx = {
                prober = "http";
                http.valid_status_codes = [ 200 ];
              };
            }
          );
        };
      };
      scrapeConfigs = [
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
        {
          job_name = "node";
          static_configs = [ { targets = [ "localhost:9100" ]; } ];
        }
        {
          job_name = "loki";
          static_configs = [
            {
              targets = [ "localhost:${toString config.layers.layer-20.services.config.monitoring.loki.port}" ];
            }
          ];
        }
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
        # Hermes API health
        {
          job_name = "blackbox-hermes";
          metrics_path = "/probe";
          params.module = [ "http_2xx" ];
          static_configs = [
            {
              targets = [
                "http://127.0.0.1:8642/health"
                "http://127.0.0.1:8010/health"
              ];
            }
          ];
          relabel_configs = [
            {
              source_labels = [ "__address__" ];
              target_label = "__param_target";
            }
            {
              source_labels = [ "__param_target" ];
              target_label = "instance";
            }
            {
              replacement = "127.0.0.1:9115";
              target_label = "__address__";
            }
          ];
        }
      ];
    };
    # ============================================================================
    # ALLOY - Log Shipper (journald → Loki) — Promtail successor
    # ============================================================================
    services.alloy = {
      enable = true;
      configPath = "/etc/alloy";
    };

    environment.etc."alloy/config.alloy".text = ''
      logging {
        level = "warn"
      }
      loki.source.journal "hermes"  {
        max_age = "12h"
        forward_to = [loki.write.default.receiver]
        labels = {
          job     = "systemd-journal",
          host    = "${config.networking.hostName}",
        }
        relabel_rules = [{
          source_labels = ["__journal__systemd_unit"],
          target_label  = "unit",
        }, {
          source_labels = ["__journal__hostname"],
          target_label  = "hostname",
        }]
      }
      loki.write "default" {
        endpoint {
          url = "http://127.0.0.1:${toString config.layers.layer-20.services.config.monitoring.loki.port}/loki/api/v1/push"
        }
      }
    '';

    # Fix DynamicUser + ConfigurationDirectory conflict with impermanence
    systemd.services.alloy.serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "alloy";
      Group = "alloy";
      ConfigurationDirectory = lib.mkForce "alloy";
    };

    users.users.alloy = {
      isSystemUser = true;
      group = "alloy";
      description = "Grafana Alloy Daemon";
    };
    users.groups.alloy = { };
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
        memberlist.bind_addr = [ "127.0.0.1" ];
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
        schema_config.configs = [
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
          admin_password = "$__file{${config.sops.secrets.grafana_admin_password.path}}";
          secret_key = "$__file{${config.clan.core.vars.generators.grafana.files."secret-key".path}}";
        };
      };
      provision.datasources = {
        settings.apiVersion = 1;
        settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            uid = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.layers.layer-20.services.config.monitoring.prometheus.port}";
            isDefault = true;
          }
          {
            name = "Loki";
            type = "loki";
            uid = "loki";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.layers.layer-20.services.config.monitoring.loki.port}";
          }
        ];
      };
      provision.dashboards = {
        settings = {
          apiVersion = 1;
          providers = [
            {
              name = "hermes-dashboards";
              orgId = 1;
              folder = "";
              type = "file";
              disableDeletion = false;
              updateIntervalSeconds = 30;
              allowUiUpdates = true;
              options.path = pkgs.symlinkJoin {
                name = "grafana-dashboards";
                paths = [ ./dashboards ];
              };
            }
          ];
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
