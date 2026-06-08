{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-20.services.config.ci.auto-update;
in
{
  options.layers.layer-20.services.config.ci.auto-update = {
    enable = lib.mkEnableOption "Weekly auto-update timer";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.nfp-auto-update = {
      description = "Update NFP flake inputs and rebuild";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        # Script needs to be written to securely run update, build, commit, and push
        ExecStart = "${pkgs.writeShellScript "nfp-auto-update" ''
          set -e
          cd /home/t0psh31f/Clan/NFP
          nix flake update
          git add flake.lock
          # Only commit if there are changes
          if ! git diff --cached --quiet; then
            git commit -m "chore: auto-update flake inputs"
            git push origin main
          fi
        ''}";
      };
    };

    systemd.timers.nfp-auto-update = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
    };
  };
}
