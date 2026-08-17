# Hermes Evaluator — Daily audit & benchmarking for Hermes profiles
# Runs as a systemd timer, produces reports and optimization proposals.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-76.hermes-evaluator;
in
{
  options.layers.layer-76.hermes-evaluator = {
    enable = mkEnableOption "Hermes Evaluator — daily audit & benchmarking";

    schedule = mkOption {
      type = types.str;
      default = "*-*-* 04:00:00";
      description = "systemd calendar expression for when to run the evaluator";
    };
  };

  config = mkIf cfg.enable {
    # Evaluator script and config
    home.file.".hermes/evaluator/scripts/hermes-evaluator.py" = {
      source = ./hermes-evaluator.py;
      executable = true;
    };

    home.file.".hermes/evaluator/SOUL.md" = {
      source = ./SOUL.md;
    };

    home.file.".hermes/evaluator/AGENTS.md" = {
      source = ./AGENTS.md;
    };

    home.file.".hermes/evaluator/config.yaml" = {
      source = ./config.yaml;
    };

    # Systemd service
    systemd.user.services.hermes-evaluator = {
      Unit = {
        Description = "Hermes Evaluator — Daily Audit & Benchmarking";
        After = [ "network.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.python3}/bin/python3 ${config.home.homeDirectory}/.hermes/evaluator/scripts/hermes-evaluator.py";
        TimeoutStartSec = 600;
        Nice = 19;
        IOSchedulingClass = "idle";
      };
    };

    # Systemd timer
    systemd.user.timers.hermes-evaluator = {
      Unit = {
        Description = "Hermes Evaluator — Daily Timer";
        Requires = [ "hermes-evaluator.service" ];
      };
      Timer = {
        OnCalendar = cfg.schedule;
        Persistent = true;
        RandomizedDelaySec = 300;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
