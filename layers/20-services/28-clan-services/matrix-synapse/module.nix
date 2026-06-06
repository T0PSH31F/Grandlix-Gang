{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.clan.services.matrix-synapse;
in
{
  _class = "clan.service";
  manifest.name = "clan-core/matrix-synapse";
  manifest.description = "Official Matrix Synapse homeserver for secure communication";
  manifest.categories = [ "Communication" ];

  roles.default = {
    interface.options = {
      serverName = mkOption {
        type = types.str;
        default = "matrix.local";
        description = "The domain name of the Matrix homeserver";
      };
      
      # Following the pattern from clan docs for official services
      enable = mkEnableOption "Matrix Synapse homeserver";
    };

    perInstance = { settings, ... }: {
      nixosModule = { config, ... }: {
        services.matrix-synapse = {
          enable = true;
          settings = {
            server_name = settings.serverName;
            database = {
              name = "psycopg2";
              args = {
                user = "matrix-synapse";
                database = "matrix-synapse";
                allow_unsafe_locale = true; # Critical for existing database compatibility
              };
            };
          };
        };

        # Infrastructure requirements
        services.postgresql = {
          enable = true;
          ensureDatabases = [ "matrix-synapse" ];
          ensureUsers = [
            {
              name = "matrix-synapse";
              ensureDBOwnership = true;
            }
          ];
        };

        # Persistence integration
        environment.persistence."/persist" = mkIf config.layers.layer-10.system.config.impermanence.enable {
          directories = [
            "/var/lib/matrix-synapse"
            "/var/lib/postgresql"
          ];
        };
      };
    };
  };
}
