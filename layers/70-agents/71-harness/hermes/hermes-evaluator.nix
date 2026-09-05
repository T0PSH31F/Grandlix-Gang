# Hermes Evaluator — Daily audit & benchmarking for Hermes profiles
# Runs as a systemd timer, scores agent progress against evaluator-rubric.md and records to harness-scores.md.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.layers.layer-76.hermes-evaluator = {
    enable = mkEnableOption "Hermes Evaluator — daily audit & benchmarking";

    schedule = mkOption {
      type = types.str;
      default = "*-*-* 04:00:00";
      description = "systemd calendar expression for when to run the evaluator";
    };
  };

  nixos = { };

  home =
    let
      cfg = config.layers.layer-76.hermes-evaluator;
      evaluatorScript = pkgs.writeShellApplication {
        name = "hermes-evaluator-harness";
        runtimeInputs = [
          pkgs.jq
          pkgs.gnugrep
          pkgs.coreutils
          pkgs.nix
        ];
        text = ''
          REPO_DIR="/home/t0psh31f/Clan/NFP"
          if [ -d "$REPO_DIR" ]; then
            cd "$REPO_DIR"
            TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
            echo "## Evaluation Run: $TIMESTAMP" >> harness-scores.md
            if [ -f feature_list.json ]; then
              PASSING_COUNT=$(jq '[.features[] | select(.state=="passing")] | length' feature_list.json)
              TOTAL_COUNT=$(jq '.features | length' feature_list.json)
              echo "- Feature progress: $PASSING_COUNT / $TOTAL_COUNT passing" >> harness-scores.md
            fi
            if [ -f agent-progress.md ]; then
              LAST_ENTRY=$(tail -n 15 agent-progress.md)
              echo "- Latest Progress Entry:" >> harness-scores.md
              echo "\`\`\`" >> harness-scores.md
              echo "$LAST_ENTRY" >> harness-scores.md
              echo "\`\`\`" >> harness-scores.md
            fi
            echo "" >> harness-scores.md
          fi
        '';
      };
    in
    mkIf cfg.enable {
    home.packages = [ evaluatorScript ];

    # Systemd service
    systemd.user.services.hermes-evaluator = {
      Unit = {
        Description = "Hermes Evaluator — Daily Audit & Benchmarking";
        After = [ "network.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${evaluatorScript}/bin/hermes-evaluator-harness";
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
