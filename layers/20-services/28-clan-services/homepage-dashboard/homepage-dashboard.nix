{
  config,
  pkgs,
  ...
}:

{
  clan.core.vars.generators.homepage-dashboard = {
    files."api_keys" = {
      secret = true;
    };
    files."port" = {
      secret = false;
    };
    script = ''
      echo "sonarr=$(${pkgs.openssl}/bin/openssl rand -hex 32)" > "$out"/api_keys
      echo "radarr=$(${pkgs.openssl}/bin/openssl rand -hex 32)" >> "$out"/api_keys
      echo "prowlarr=$(${pkgs.openssl}/bin/openssl rand -hex 32)" >> "$out"/api_keys

      echo -n "${toString config.layers.layer-20.services.config.homepage-dashboard.port}" > "$out"/port
    '';
  };

  # Import the actual module
  imports = [ ../../26-monitoring/homepage-dashboard.nix ];
}
