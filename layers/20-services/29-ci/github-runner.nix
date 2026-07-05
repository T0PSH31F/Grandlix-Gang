{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-20.services.config.ci.github-runner;
in
{
  options.layers.layer-20.services.config.ci.github-runner = {
    enable = lib.mkEnableOption "GitHub Actions runner for deployment";

    url = lib.mkOption {
      type = lib.types.str;
      default = "https://github.com/T0PSH31F/NFP";
      description = "Repository URL to register runner against";
    };
  };

  config = lib.mkIf cfg.enable {
    # Use existing GitHub PAT from SOPS (does not expire like registration tokens)
    sops.secrets."github_token" = {
      owner = "github-runner";
      group = "github-runner";
      sopsFile = ../../../00-cyberia/03-treasure/secrets/external_services.yaml;
    };

    services.github-runners.nfp-deployer = {
      enable = true;
      inherit (cfg) url;
      tokenFile = config.sops.secrets."github_token".path;
      extraPackages = with pkgs; [
        git
        nix
        jq
      ];
      extraLabels = [
        "nixos"
        "deployer"
        "nfp"
      ];
      replace = true;
    };
  };
}
