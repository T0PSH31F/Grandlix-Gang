{
  lib,
  pkgs,
  ...
}:
{
  # ============================================================================
  # 00 - CORE IMPORTS
  # ============================================================================
  imports = [
    ./hardware.nix

    ../../layers/10-system/13-users/t0psh31f.nix
  ];

  # ============================================================================
  # 01 - MACHINE IDENTITY
  # ============================================================================
  networking.hostName = "z0r0";
  system.stateVersion = "25.05";

  # Use GRUB for better reliability with this specific hardware/impermanence setup
  boot.loader = {
    systemd-boot.enable = lib.mkForce true;
    efi.canTouchEfiVariables = true;
    # grub = {
    #  enable = true;
    #  device = "nodev";
    #  efiSupport = true;
    #  useOSProber = true;
  };

  # ----------------------------------------------------------------------------
  # AVAILABLE PROFILES / TAGS
  # ----------------------------------------------------------------------------
  # Tags define the machine's role and automatically enable corresponding features.
  # See `layers/90-profiles/tags/` for explicit definitions.
  #
  # Hardware/Form Factor:
  #   "workstation" : Enables base limits, themes, and network tools (avahi, tailscale, ssh).
  #   "desktop"     : Enables graphical hardware features (bluetooth), automount, portals, flatpak.
  #   "laptop"      : Enables battery optimizations and wireless tools.
  #
  # Roles:
  #   "development" : Enables coding tools, Python, VSCode, and dev agents (Opencode, Antigravity).
  #   "gaming"      : Enables Steam, GameMode, Lutris, emulators, etc.
  #   "ai-server"   : Enables local AI backend (llms, sillytavern, wyoming, ai-services, dashboard).
  #   "homelab"     : Enables home infra (home-assistant, searxng, headscale, vaultwarden, etc).
  #   "cache-server": Enables Harmonia Nix binary cache.
  #   "media-server": Enables the *arr stack, Jellyfin, Deluge, etc.
  # ----------------------------------------------------------------------------

  # ============================================================================
  # 02 - LAYERED FEATURE FLAGS (Overrides)
  # ============================================================================
  # Note: Most features are automatically enabled via machine.tags -> 90-profiles
  layers = {
    layer-10.system = {
      hardware.kernel = "zen"; # Zen is best for laptops (responsiveness without thermal/battery penalty)
      peripherals.corsair.enable = true;
      peripherals.openrgb.enable = true;
      peripherals.razer.enable = lib.mkForce false; # Disabled: openrazer driver incompatible with linux 7.0.10
      mobile.android.enable = true;
      config.impermanence.enable = true;
      virtualization.enable = true;
    };

    layer-20.services.config = {
      adguard.enable = true;
    };

    layer-30.theming.themes.greeter = {
      sddm.enable = false;
      greetd.enable = true;
    };

    layer-40.desktop = {
      noctalia.backend = "hyprland";
    };
  };

  # ============================================================================
  # 03 - SERVICE SPECIFICS & OVERRIDES (Layer 20)
  # ============================================================================
  # Note: Most raw services are automatically enabled via machine.tags

  # ============================================================================
  # 04 - SYSTEM & PROGRAM OVERRIDES
  # ============================================================================

  services = {
    ai-services.lmstudio.enable = lib.mkForce false; # Disabled: packaging error in unstable
    llm-agents.enable = true;
    llama-cpp-server.enable = true;
    n8n-server.enable = false;
    infrastructure.langfuse.enable = true;
  };

  layers.layer-20.services.communication.signal-cli-daemon = {
    enable = true;
    port = 8080; # matches hermes SIGNAL_HTTP_URL
  };

  systemd.services.rclone-gdrive-mount.enable = false;

  clan.core.postgresql.enable = true;

  # ============================================================================
  # 05 - SECURITY & SECRETS (SOPS/ACME)
  # ============================================================================
  sops = {
    age.keyFile = "/persist/home/t0psh31f/.config/sops/age/keys.txt";
  };

  # Matrix homeserver (luffy) + nix cache reachable via Tailscale
  networking.extraHosts = ''
    192.168.1.54 matrix.local element.local
    100.72.46.75 luffy.d luffy-1
  '';

  # ============================================================================
  # 06 - STORE INTEGRITY & SAFE GARBAGE COLLECTION
  # ============================================================================
  # BUG (nixpkgs unstable): util-linux-2.42-bin contains symlinks to sibling
  # outputs (mount, login, swap) but nix's reference metadata does NOT track
  # them as references. This means `nix-store --gc` sees these outputs as
  # unreferenced garbage and DELETES them, even though the live system needs
  # them at boot. When they're missing, prepare-root fails with
  # "mount: command not found" and the entire boot cascades to failure
  # (impermanence bind-mounts fail, /boot won't mount, firewall fails, etc).
  #
  # This happened on 2026-06-19 after forceful nix-store --gc runs.
  # See RECOVERY_NOTE.md and docs/AGENT_ONBOARDING.md for full details.
  #
  # FIX: Create gcroots for all util-linux bin symlink targets at every
  # activation so nix-store --gc preserves them. This is scoped to z0r0
  # only (luffy has the same vulnerability but is left untouched per user
  # request — consider applying the same fix to luffy in the future).

  system.activationScripts.gcroot-util-linux = ''
    mkdir -p /nix/var/nix/gcroots
    _ulbin="${pkgs.util-linux.bin}"
    if [ -d "$_ulbin/bin" ]; then
      for link in "$_ulbin"/bin/*; do
        [ -L "$link" ] || continue
        target=$(readlink -f "$link" 2>/dev/null) || continue
        case "$target" in
          /nix/store/*)
            storepath=$(echo "$target" | cut -d/ -f1-4)
            name=$(basename "$storepath")
            ln -sfn "$storepath" "/nix/var/nix/gcroots/util-linux-fix-$name"
            ;;
        esac
      done
    fi
  '';

  # Safe automatic garbage collection — only removes old generations,
  # never unreferenced paths that might have broken reference metadata.
  systemd.services.nix-safe-gc = {
    description = "Safe Nix GC (old generations only, preserves unreferenced-but-needed paths)";
    startAt = "Sun 04:00";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.nix}/bin/nix-collect-garbage --delete-older-than 14d";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };

  # Provide a safe-gc convenience script so the user doesn't reach for
  # the dangerous `nix-store --gc` out of habit.
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "nix-safe-gc" ''
      echo "Running safe garbage collection (deleting generations older than ''${1:-14d})..."
      ${pkgs.nix}/bin/nix-collect-garbage --delete-older-than "''${1:-14d}"
      echo "Done. No unreferenced-but-needed paths were harmed."
      echo ""
      echo "WARNING: Do NOT use 'nix-store --gc' or 'nix-store --gc --max-freed'"
      echo "without running 'nixos-rebuild boot' first. The util-linux broken-"
      echo "reference-metadata bug (see AGENT_ONBOARDING.md) can delete boot-"
      echo "critical paths. Use this 'nix-safe-gc' command instead."
    '')
  ];
}
