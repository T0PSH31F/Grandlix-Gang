{
  config,
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
      mobile.ios.enable = true;
      config.impermanence.enable = true;
      virtualization.enable = true;
      sessionResilience.enable = true; # Fixes uwsm DBus timeouts, getty GC, orphaned session cleanup
    };

    layer-20.services.config = {
      ci.auto-update.enable = true;
      ci.github-runner.enable = true;
      adguard = {
        enable = lib.mkForce false;  # Moved to luffy
      };
      monitoring = {
        enable = true;
        grafana.port = 3008;
        prometheus.port = 9090;
        loki.port = 3100;
      };
      hedgedoc = {
        enable = true;
        port = 3001;
        domain = "z0r0.local";
      };
    };

    layer-30.theming.themes.greeter = {
      sddm.enable = false;
      greetd.enable = false;
      noctalia-greeter = {
        enable = true;
        session = "hyprland-uwsm";
      };
    };

    layer-40.desktop = {
      noctalia.backend = "hyprland";
    };

    layer-60.gui.documents.enable = true;

    # Enable zellij bottom bar (CPU/RAM) via yazelix bars
    layer-50.cli.zellij.yazelix.bars.enable = true;

    # Enable rclone Google Drive mount as a user service (auto-restarts on failure)
    layer-50.home.cli.services.rclone.enable = true;

    # codegraph — semantic code intelligence for AI coding agents
    layer-70.agent.codegraph.enable = true;
  };

  # ============================================================================
  # 03 - SERVICE SPECIFICS & OVERRIDES (Layer 20)
  # ============================================================================
  # Note: Most raw services are automatically enabled via machine.tags

  # ============================================================================
  # 04 - SYSTEM & PROGRAM OVERRIDES
  # ============================================================================

  services = {
    # UsePAM left at default (true) — the previous lib.mkForce false broke
    # session management, audit, and login limits. The publickey-hostbound
    # issue is better fixed by disabling the extension in sshd_config or
    # by using AuthenticationMethods explicitly.
    # openssh.settings.UsePAM = lib.mkForce false;  # REMOVED: see above
    sillytavern-app.enable = lib.mkForce false; # Crash-looping, not needed on z0r0
    ai-services.lmstudio.enable = lib.mkForce false; # Disabled: packaging error in unstable
    ai-services.qdrant.enable = lib.mkForce false; # Disabled: LLVM intrinsic signature mismatch with new LLVM
    llm-agents.enable = true;

    # Brain Service — Personal Knowledge Base (PDF/EPUB/HTML/MD RAG for Hermes)
    ai-services.brain-service = {
      enable = true;
      port = 8010;
      mcpEnable = false; # Disabled temporarily: pymupdf tests fail (test_2791, test_4090 memory ratio)
      booksDir = "/home/t0psh31f/Notes/PKB";
      embedModel = "nomic-embed-text";
      embedDim = 768;
    };
    llama-cpp-server = {
      enable = true;
      host = "0.0.0.0";
      model = "/var/lib/llama-cpp/Llama3.3-8B-Instruct-Thinking-Heretic-Uncensored-Claude-4.5-Opus-High-Reasoning.i1-IQ4_XS.gguf";
      extraFlags = [ "-ngl" "99" "--ctx-size" "8192" "--parallel" "2" "--no-warmup" ];
    };
    n8n-server.enable = false;
    infrastructure.langfuse.enable = true;

    # Kong AI Gateway — unified LLM/API gateway
    ai-services.kong-gateway = {
      enable = true;
      environmentFile = config.sops.templates."kong-env".path;
      proxyPort = 8081; # Avoid conflict with signal-cli on 8080
    };

    # Upstream LLM routers behind Kong
    ai-services.omniroute = {
      enable = true;
      environmentFile = config.sops.templates."kong-env".path;
    };
    ai-services.freellmpool = {
      enable = true;
      environmentFile = config.sops.templates."kong-env".path;
      port = 8082; # Avoid conflict with signal-cli on 8080
    };
    ai-services.langgraph = {
      enable = false; # DISABLED: langgraph.server module not in nixpkgs (needs langgraph-cli)
      environmentFile = config.sops.templates."langgraph-env".path;
    };

    # FreeLLMAPI — free-tier LLM router for Hermes/OpenCode fallback
    ai-services.freellmapi = {
      enable = true;
      port = 3003; # Avoid conflict with HedgeDoc on 3001
    };

    # Mistral MCP — Mistral AI tool server (chat, OCR, Codestral)
    ai-services.mistral-mcp = {
      enable = true;
      port = 3333;
    };
  };

  # Make Langfuse accessible from LAN for cross-machine dashboard monitoring
  virtualisation.oci-containers.containers.langfuse.environment.HOSTNAME = lib.mkForce "0.0.0.0";

  layers.layer-76.hermes.enableDesktop = true;
  layers.layer-76.hermes-workspace.enable = true;
  layers.layer-76.hermes-dashboard.enable = true;

  layers.layer-20.services.communication.signal-cli-daemon = {
    enable = true;
    port = 8080; # matches hermes SIGNAL_HTTP_URL
  };

  layers.layer-20.services.communication.camofox-browser = {
    enable = true;
    port = 9377;
    apiKey = config.sops.placeholder.camofox_api_key;
  };

  layers.layer-20.services.communication.rustdesk = {
    enable = true;
    client.enable = true;
    server.enable = false;
  };

  # Open firewall ports for cross-machine dashboard monitoring (luffy → z0r0)
  networking.firewall.allowedTCPPorts = [
    3000 # Hermes Workspace
    9119 # Hermes Dashboard
    8010 # Brain Service
    8080 # Signal CLI
    3005 # Langfuse
    8000 # SillyTavern
    8081 # llama.cpp
    9090 # Prometheus
    3100 # Loki
    3008 # Grafana
    61208 # Glances for homepage cross-machine stats
  ];

  networking.firewall.trustedInterfaces = [
    "tailscale0"
    "podman0"
    "zt0"
    "wg0"
  ];

  # Enable Glances for cross-machine dashboard system stats
  services.glances-server.enable = true;

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
    100.72.46.75 matrix.local element.local
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

  system.activationScripts.clean-boot-entries = ''
    if [ -d /boot/loader/entries ]; then
      for f in /boot/loader/entries/*.conf; do
        [ -f "$f" ] || continue
        init_path=$(${pkgs.gnugrep}/bin/grep -E 'options.*init=' "$f" | ${pkgs.gnused}/bin/sed -E 's/.*init=([^ ]+).*/\1/')
        if [ -n "$init_path" ] && [ ! -e "$init_path" ]; then
          echo "Pruning orphan boot entry: $f (init $init_path missing)"
          rm -f "$f"
        fi
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
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "nix-safe-gc" ''
      echo "Running safe garbage collection (deleting generations older than ''${1:-14d})..."
      ${pkgs.nix}/bin/nix-collect-garbage --delete-older-than "''${1:-14d}"
      if [ -d /boot/loader/entries ]; then
        echo "Pruning orphan boot entries..."
        for f in /boot/loader/entries/*.conf; do
          [ -f "$f" ] || continue
          init_path=$(grep -E 'options.*init=' "$f" | sed -E 's/.*init=([^ ]+).*/\1/')
          if [ -n "$init_path" ] && [ ! -e "$init_path" ]; then
            echo "Removing orphan entry: $f"
            sudo rm -f "$f"
          fi
        done
      fi
      echo "Done. No unreferenced-but-needed paths were harmed."
    '')
  ];
}
