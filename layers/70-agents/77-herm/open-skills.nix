{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-77.open-skills;
  openSkillsSrc = pkgs.fetchFromGitHub {
    owner = "besoeasy";
    repo = "open-skills";
    rev = "3bc011321c9054238d207936dbb577aa4b7e0e4d";
    hash = "sha256-Bd/2zDB4b31IvsF/YSeFwYXERBuZlG1e8cFTMnuvOlM=";
  };
in
{
  options.layers.layer-77.open-skills = {
    enable = mkEnableOption "Open Skills — battle-tested skill library for AI agents";
  };

  home = { ... }: {
    config = mkIf cfg.enable {
      home.file.".hermes/open-skills" = {
        source = openSkillsSrc;
        recursive = true;
      };
    };
  };
}
