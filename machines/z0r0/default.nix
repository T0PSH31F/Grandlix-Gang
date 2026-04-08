{
  config,
  lib,
  ...
}:
{
  imports = [
    # Hardware configuration (LUKS, filesystems, swap)
    ./hardware.nix

    # Core system modules from flake-parts (includes base, nix-settings, networking, nix-tools, clan-lib, fonts, overlays)
    ../../flake-parts/system
    ../../flake-parts/hardware
    ../../flake-parts/themes
    ../../flake-parts/features/nixos

    ../../flake-parts/services/ai
    ../../flake-parts/services/media
    ../../flake-parts/services/infrastructure
    ../../flake-parts/services/communication

    # User configuration (HM + user-specific system settings)
    ../../flake-parts/users/t0psh31f.nix
  ];

  # ============================================================================
  # MACHINE METADATA
  # ============================================================================
  networking.hostName = "z0r0";
  system.stateVersion = "25.05";

  machine.tags = [
    "desktop"
    "laptop"
    "ai-server"
    "build-server"
    "binary-cache"
    "database"
    "dev"
    "media-server"
  ];

  # ============================================================================
  # FEATURE TOGGLES
  # ============================================================================

  hardware-config = {
    automount.enable = true;
    openrgb.enable = true;
    bluetooth.enable = true;
    corsair.enable = true;
  };

  # Themes
  themes = {
    grub-lain.enable = true;
    plymouth-hellonavi.enable = true;
    greeter = {
      greetd = {
        enable = true;
        background = ../../assets/sddm_background/roronoa-zoro_800.gif;
      };
      sddm = {
        enable = false;
        background = ../../assets/sddm_background/roronoa-zoro_800.gif;
      };
    };
  };

  # Mobile device support
  mobile = {
    android.enable = true;
    ios.enable = false;
  };

  # System features
  nix-tools.enable = true;
  desktop-portals.enable = true;

  # Gaming & Virtualization
  gaming.enable = true;
  virtualization.enable = true;

  # Flatpak & AppImage
  flatpak.enable = true;

  # Impermanence
  system-config.impermanence.enable = true;

  # ============================================================================
  # SERVICES
  # ============================================================================

  services = {
    # Desktop Services
    ssh-agent.enable = true;
    searxng.enable = true;
    pastebin.enable = false;
    wyoming-services.enable = true;

    # DuckDNS Auto-Updater using dd
    ddclient = {
      enable = true;
      domains = [
        "lovelain.duckdns.org"
        "t0psh31f.duckdns.org"
        "nixfp.duckdns.org"
      ];
      protocol = "duckdns";
      passwordFile = config.sops.secrets."duckdns-token".path;
    };

    # Home Automation & Infrastructure
    home-assistant-server.enable = true;
    caddy-server = {
      enable = true;
      email = "admin@lovelain.duckdns.org";
      virtualHosts."headscale.lovelain.duckdns.org" = {
        useACMEHost = "lovelain.duckdns.org";
        extraConfig = ''
          encode zstd gzip
          header Strict-Transport-Security "max-age=31536000; includeSubDomains"
          reverse_proxy localhost:8086
        '';
      };
    };
    n8n-server.enable = false;

    # AI Services - Granular toggles
    llm-agents.enable = true;
    sillytavern.enable = true;
    librechat.enable = false;
    ai-services = {
      enable = true;
      open-webui.enable = false;
      localai.enable = false;
      chromadb.enable = true;
      qdrant.enable = false;
      lmstudio.enable = true;
      jan.enable = true;
      cherry-studio.enable = false;
      aider.enable = true;
    };

    # Media & Cloud
    immich-server.enable = false; # Moved to Nami
    calibre-web-app.enable = false; # Moved to Nami
    nextcloud-server.enable = false; # Moved to Nami
    komga.enable = false;

    # Communication
    matrix-server.enable = false;
    mautrix-bridges.enable = false; # Moved to Nami

    # Extra Services
    glances-server.enable = true;
    filebrowser-app.enable = true;
    deluge-server.enable = false; # Moved to Nami
    transmission-server.enable = false;
    headscale-server.enable = true;
    harmonia.cache.enable = true;
  };

  # Resource limits enabled for stabilization
  system-config.resource-limits.enable = true;

  # Services config (separate namespace for config-only services)
  services-config = {
    adguard.enable = true; # Added explicit toggle
    media-stack.enable = false; # Toggle for *arr suite
    karakeep.enable = false;
    your-spotify.enable = false;
    avahi.enable = true; # mDNS
    monitoring.enable = true;
    homepage-dashboard.enable = true;
    homepage-dashboard.lovable.enable = true;
    tailscale.enable = true;
  };

  programs.niri.enable = lib.mkForce false;

  # ============================================================================
  # HOME MANAGER OVERRIDES
  # ============================================================================
  home-manager.users.t0psh31f = {
    desktop.noctalia.backend = "hyprland";
    features.home.agent = {
      opencode = {
        enable = true;
        desktop = true;
      };
      gemini-cli.enable = true;
      asr-tts.enable = true;
      antigravity.enable = true;
    };

    programs.cli-environment.pythonTools.enable = true;
  };

  # ============================================================================
  # SOPS SECRETS
  # ============================================================================
  sops.age.keyFile = "/home/t0psh31f/.config/sops/age/keys.txt";
  sops.secrets."duckdns-token" = {
    sopsFile = lib.mkForce ../../treasure/secrets/duckdns.yaml;
    format = lib.mkForce "yaml";
  };
  sops.templates."duckdns-env".content = ''
    DUCKDNS_TOKEN=${config.sops.placeholder."duckdns-token"}
  '';

  # ============================================================================
  # SECURITY / ACME / DUCKDNS
  # ============================================================================
  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@lovelain.duckdns.org";
    certs."lovelain.duckdns.org" = {
      domain = "*.lovelain.duckdns.org";
      extraDomainNames = [
        "lovelain.duckdns.org"
        "t0psh31f.duckdns.org"
        "nixfp.duckdns.org"
      ];
      dnsProvider = "duckdns";
      environmentFile = config.sops.templates."duckdns-env".path;
    };
  };

}
