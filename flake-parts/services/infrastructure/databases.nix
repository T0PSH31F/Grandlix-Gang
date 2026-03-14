# flake-parts/services/infrastructure/databases.nix
# Centralized persistence for common databases.
# Uses global config.services.<db>.enable to automatically detect if a database
# is required by ANY enabled service (e.g. Matrix, Nextcloud, Home Assistant),
# even if it's enabled implicitly by those modules.
{ config, lib, ... }:
with lib;
{
  config = mkIf config.system-config.impermanence.enable {
    environment.persistence."/persist" = {
      directories =
        (optional (config.services.postgresql.enable or false) "/var/lib/postgresql")
        ++ (optional (config.services.mysql.enable or false) "/var/lib/mysql")
        ++ (optional (config.services.redis.servers != { }) "/var/lib/redis")
        ++ (optional (lib.hasAttr "nextcloud" (
          config.services.redis.servers or { }
        )) "/var/lib/redis-nextcloud")
        ++ (optional (config.services.mongodb.enable or false) "/var/lib/mongodb")
        ++ (optional (config.services.influxdb.enable or false) "/var/lib/influxdb")
        ++ (optional (config.services.victoriametrics.enable or false) "/var/lib/victoriametrics");
    };
  };
}
