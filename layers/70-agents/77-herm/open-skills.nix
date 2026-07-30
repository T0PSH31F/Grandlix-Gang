{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-77.open-skills;
  repoUrl = "https://github.com/besoeasy/open-skills";
  primaryUser = config.layers.meta.primaryUser or "t0psh31f";
  homeDir = config.users.users.${primaryUser}.home;
  skillDir = "${homeDir}/.hermes/open-skills";
in
{
  options.layers.layer-77.open-skills = {
    enable = mkEnableOption "Open Skills — battle-tested skill library for AI agents";
  };

  home = { ... }: {
    config = mkIf cfg.enable {
      home.packages = [ pkgs.git ];

      home.activation.installOpenSkills = {
        data = ''
          if [ ! -d "${skillDir}" ]; then
            run ${pkgs.git}/bin/git clone ${repoUrl} "${skillDir}"
          else
            run ${pkgs.git}/bin/git -C "${skillDir}" pull --ff-only || true
          fi
        '';
        before = [ ];
        after = [ "writeBoundary" ];
      };
    };
  };
}
