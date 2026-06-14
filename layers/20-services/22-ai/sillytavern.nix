{
  config,
  lib,
  ...
}:
with lib;
{
  options.services.sillytavern-app = {
    enable = mkEnableOption "SillyTavern service";

    port = mkOption {
      type = types.int;
      default = 8000;
      description = "SillyTavern port";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/SillyTavern";
      description = "Data directory for SillyTavern";
    };
  };

  options.clan.services.ai.sillytavern = {
    enable = mkEnableOption "SillyTavern Clan Service";
  };

  config =
    mkIf (config.services.sillytavern-app.enable || config.clan.services.ai.sillytavern.enable)
      {
        # Native NixOS SillyTavern service
        services.sillytavern = {
          enable = true;
          port = config.services.sillytavern-app.port;
          listen = true; # Listen on all interfaces
        };

        # Firewall
        networking.firewall.allowedTCPPorts = [ config.services.sillytavern-app.port ];

        # Ensure data is persisted
        environment.persistence."/persist" =
          mkIf (config.layers.layer-10.system.config.impermanence.enable or false)
            {
              directories = [
                {
                  directory = "/var/lib/SillyTavern";
                  user = "sillytavern";
                  group = "sillytavern";
                  mode = "0755";
                }
              ];
            };
      };
}
