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
      default = "https://github.com/T0PSH31F/Grandlix-Gang";
      description = "Repository or org URL to register runner against";
    };
    
    tokenFile = lib.mkOption {
      type = lib.types.path;
      default = config.sops.secrets."github-runner/token".path or "/run/secrets/github-runner/token";
      description = "Path to file containing registration token";
    };
  };

  config = lib.mkIf cfg.enable {
    # Provide the token via sops
    sops.secrets."github-runner/token" = {
      owner = "github-runner";
      group = "github-runner";
      sopsFile = ../../../00-cyberia/03-secrets/secrets.yaml;
    };

    services.github-runners.nfp-deployer = {
      enable = true;
      inherit (cfg) url tokenFile;
      extraPackages = with pkgs; [
        git
        nix
        jq
      ];
      extraLabels = [ "nixos" "deployer" "nfp" ];
      replace = true;
    };
  };
}
