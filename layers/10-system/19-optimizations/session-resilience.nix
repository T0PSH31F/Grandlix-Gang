# Session Resilience Module
# Fixes: uwsm DBus timeouts, getty GC, orphaned session cleanup
# Addresses the recurring issue where sessions crash and lock out the user
{ config, lib, pkgs, ... }:

let
  cfg = config.layers.layer-10.system.sessionResilience;

  # ── Session cleanup script ──────────────────────────────────────────
  # Runs at boot BEFORE greetd to kill any orphaned Wayland sessions
  # from a previous crash, preventing the "can't re-login" lockout.
  session-cleanup-script = pkgs.writeShellScript "session-cleanup" ''
    set -euo pipefail

    log() { echo "session-cleanup: $1" | systemd-cat -t session-cleanup 2>/dev/null || true; }

    log "Starting orphaned session cleanup..."

    # Iterate over user runtimes to find UID >= 1000
    for uid_dir in /run/user/*/; do
      uid_num="''${uid_dir#/run/user/}"
      uid_num="''${uid_num%/}"
      [ "$uid_num" -ge 1000 ] 2>/dev/null || continue

      # Check if this user has a graphical session via loginctl
      # Format: SESSION USER SERVICE TTY seat TIMESTAMP
      sessions=$(loginctl list-sessions --no-legend 2>/dev/null | awk -v uid="$uid_num" '$2 == uid {print $1, $3}' || true)

      if [ -z "$sessions" ]; then
        continue
      fi

      for session_info in $sessions; do
        sess_id=$(echo "$session_info" | awk '{print $1}')
        sess_svc=$(echo "$session_info" | awk '{print $2}')

        # Only care about greetd sessions (graphical logins)
        [ "$sess_svc" = "greetd" ] || continue

        # Check if the user's systemd is actually running
        if ! systemctl --user -M "''${uid_num}@" is-system-running --wait 2>/dev/null | head -1 | grep -qE "running|degraded"; then
          log "UID $uid_num: user systemd not running (session $sess_id via greetd) — terminating stale session"
          loginctl terminate-session "$sess_id" 2>/dev/null || true
        fi
      done
    done

    # Give greetd a moment to process the terminations
    sleep 1

    log "Orphaned session cleanup complete"
  '';

  # ── uwsm DBus readiness waiter ──────────────────────────────────────
  # Pre-start script for uwsm env-preloader that waits for the user
  # D-Bus session bus to be responsive, preventing the NoReply timeout
  # that crashes the entire session.
  uwsm-dbus-wait-script = pkgs.writeShellScript "uwsm-dbus-wait" ''
    set -euo pipefail

    log() { echo "uwsm-dbus-wait: $1" | systemd-cat -t uwsm-dbus-wait 2>/dev/null || true; }

    # Wait up to 20s for the user D-Bus session bus
    for i in $(seq 1 40); do
      if busctl --user status >/dev/null 2>&1; then
        log "D-Bus session bus ready after $((i * 500))ms"
        exit 0
      fi
      # busctl itself might not exist yet; try DBUS_SESSION_BUS_ADDRESS
      if [ -n "''${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
        if busctl --user >/dev/null 2>&1; then
          log "D-Bus session bus ready after $((i * 500))ms"
          exit 0
        fi
      fi
      sleep 0.5
    done

    log "WARNING: D-Bus session bus not ready after 20s, proceeding anyway"
    exit 0  # Don't block — let uwsm try and handle its own errors
  '';

  # ── Per-user session recovery check ─────────────────────────────────
  # Checks if the current boot's uwsm services are in a broken state
  # (env-preloader failed but compositor unit still lingering) and
  # resets them so greetd can start a fresh session.
  session-recovery-script = pkgs.writeShellScript "session-recovery" ''
    set -euo pipefail

    log() { echo "session-recovery: $1" | systemd-cat -t session-recovery 2>/dev/null || true; }

    # Check for user uids with runtime dirs
    for uid_dir in /run/user/*/; do
      uid_num="''${uid_dir#/run/user/}"
      uid_num="''${uid_num%/}"
      [ "$uid_num" -ge 1000 ] 2>/dev/null || continue

      # Try to check uwsm state for this user
      # If wayland-wm-env failed but the session envelope target is still up,
      # we need to reset it so a new session can start.
      env_state=$(systemctl --user -M "''${uid_num}@" is-failed wayland-wm-env@Hyprland.service 2>/dev/null || echo "unknown")
      wm_state=$(systemctl --user -M "''${uid_num}@" is-active wayland-wm@Hyprland.service 2>/dev/null || echo "unknown")

      if [ "$env_state" = "failed" ] && [ "$wm_state" != "active" ]; then
        log "UID $uid_num: env-preloader failed, compositor not running — resetting uwsm state"

        # Reset failed services so they can be started fresh
        systemctl --user -M "''${uid_num}@" reset-failed --all 2>/dev/null || true

        # Stop all wayland-related targets/services for clean slate
        systemctl --user -M "''${uid_num}@" stop wayland-session-envelope@Hyprland.target 2>/dev/null || true
        systemctl --user -M "''${uid_num}@" stop graphical-session.target 2>/dev/null || true
        systemctl --user -M "''${uid_num}@" stop hyprland-session.target 2>/dev/null || true

        log "UID $uid_num: uwsm state reset"
      fi
    done

    log "Session recovery check complete"
  '';
in
{
  options.layers.layer-10.system.sessionResilience = {
    enable = lib.mkEnableOption "Session resilience (getty pinning, uwsm DBus fixes, orphan cleanup)";
  };

  config = lib.mkIf cfg.enable {
    # ============================================================================
    # 1. GETTY GC PROTECTION
    # ============================================================================
    # Ensure the agetty binary and the systemd package (which provides
    # getty@.service) are pinned as GC roots so they survive
    # nix-collect-garbage / nix-store --gc.
    #
    # The existing gcroot-util-linux script in z0r0/default.nix pins
    # util-linux symlinks, but we also need to pin the systemd package
    # and the NixOS-generated getty wrapper paths.

    system.activationScripts.gcroot-getty = ''
      mkdir -p /nix/var/nix/gcroots

      # Pin the systemd package (contains getty@.service unit file)
      for _out in "${pkgs.systemd}" "${pkgs.systemd}/example"; do
        [ -d "$_out" ] || continue
        _storepath=$(readlink -f "$_out" 2>/dev/null | grep -o '/nix/store/[^ ]*' | head -1)
        [ -n "$_storepath" ] || continue
        _name=$(basename "$_storepath")
        ln -sfn "$_storepath" "/nix/var/nix/gcroots/systemd-''${_name}"
      done

      # Pin agetty from util-linux (the actual binary)
      _agetty="${pkgs.util-linux}/bin/agetty"
      if [ -e "$_agetty" ]; then
        _storepath=$(readlink -f "$_agetty" 2>/dev/null | grep -o '/nix/store/[^ ]*' | head -1)
        if [ -n "$_storepath" ]; then
          _name=$(basename "$_storepath")
          ln -sfn "$_storepath" "/nix/var/nix/gcroots/agetty-''${_name}"
        fi
      fi
    '';

    # ============================================================================
    # 2. UWSM DBUS TIMEOUT RESILIENCE
    # ============================================================================
    # Create a systemd drop-in override for wayland-wm-env@.service that:
    #   - Waits for D-Bus before running the env-preloader
    #   - Increases the start timeout from 30s to 60s
    #   - Adds Restart=on-failure with retry limits so transient DBus
    #     timeouts don't immediately trigger OnFailure=wayland-session-shutdown
    #
    # NOTE: environment.etc cannot create directories with '@' in the name
    # (Permission denied in nix build sandbox). Activation scripts can't write
    # to /etc under impermanence (read-only). Use tmpfiles rules only — they
    # run after /etc is set up and can create directories with '@' in names.

    systemd.tmpfiles.rules = [
      "d /etc/systemd/user/wayland-wm-env@.service.d 0755 root root -"
      "d /etc/systemd/user/wayland-wm@.service.d 0755 root root -"
    ];

    # Use a systemd service to write drop-in files after tmpfiles creates dirs
    systemd.services.wayland-wm-env-drops = {
      description = "Write wayland-wm-env drop-in overrides";
      after = [ "systemd-tmpfiles-setup.service" ];
      requires = [ "systemd-tmpfiles-setup.service" ];
      before = [ "systemd-user-sessions.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      script = let
        waylandWmEnvConf = pkgs.writeText "10-session-resilience.conf" ''
          [Unit]
          StartLimitBurst=3
          StartLimitIntervalSec=30

          [Service]
          ExecStartPre=${uwsm-dbus-wait-script}
          TimeoutStartSec=60
          Restart=on-failure
          RestartSec=5
        '';
        waylandWmConf = pkgs.writeText "10-session-resilience.conf" ''
          [Service]
          TimeoutStartSec=45
        '';
      in ''
        mkdir -p /etc/systemd/user/wayland-wm-env@.service.d
        cp -f ${waylandWmEnvConf} /etc/systemd/user/wayland-wm-env@.service.d/10-session-resilience.conf
        mkdir -p /etc/systemd/user/wayland-wm@.service.d
        cp -f ${waylandWmConf} /etc/systemd/user/wayland-wm@.service.d/10-session-resilience.conf
      '';
    };

    # ============================================================================
    # 3. BOOT-TIME SESSION CLEANUP
    # ============================================================================
    # Two services that run before greetd:
    #   - session-cleanup: terminates stale login sessions from crashed boots
    #   - session-recovery: resets broken uwsm service state so fresh login works

    systemd.services.session-cleanup = {
      description = "Clean up orphaned Wayland sessions from previous boot";
      after = [ "multi-user.target" ];
      before = [ "greetd.service" ];
      wantedBy = [ "greetd.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = session-cleanup-script;
        SuccessExitStatus = "0 1";
        TimeoutStartSec = 15;
      };
    };

    systemd.services.session-recovery = {
      description = "Reset broken uwsm state from previous boot";
      after = [ "session-cleanup.service" ];
      before = [ "greetd.service" ];
      wantedBy = [ "greetd.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = session-recovery-script;
        SuccessExitStatus = "0 1";
        TimeoutStartSec = 15;
      };
    };
  };
}
