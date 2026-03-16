{
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

  services-config.tailscale.enable = true;

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

  # System features
  nix-tools.enable = true;
  desktop-portals.enable = true;

  hardware-config = {
    automount.enable = true;
    openrgb.enable = true;
    bluetooth.enable = true;
  };

  # Themes
  themes = {
    grub-lain.enable = true;
    plymouth-hellonavi.enable = true;
  };

  # Mobile device support
  mobile = {
    android.enable = true;
    ios.enable = false;
  };

  # Gaming & Virtualization
  gaming.enable = false;
  virtualization.enable = false;

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
    pastebin.enable = true;

    # Home Automation & Infrastructure
    home-assistant-server.enable = true;
    caddy-server.enable = false;
    n8n-server.enable = false;

    # AI Services - Granular toggles
    llm-agents.enable = true;
    sillytavern.enable = false;
    librechat.enable = false;
    ai-services = {
      enable = true;
      open-webui.enable = true;
      localai.enable = false;
      chromadb.enable = false;
      qdrant.enable = false;
      lmstudio.enable = false;
      jan.enable = true;
      cherry-studio.enable = true;
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
    headscale-server.enable = false;
    harmonia.cache.enable = true;
  };

  # Resource limits enabled for stabilization
  system-config.resource-limits.enable = true;

  # Services config (separate namespace for config-only services)
  services-config = {
    adguard.enable = false; # Added explicit toggle
    media-stack.enable = false; # Toggle for *arr suite
    karakeep.enable = false;
    your-spotify.enable = false;
    avahi.enable = true; # mDNS
    monitoring.enable = true;
    homepage-dashboard.enable = true;
    homepage-dashboard.lovable.enable = true;
  };

  programs.niri.enable = lib.mkForce false;

  # ============================================================================
  # HOME MANAGER OVERRIDES
  # ============================================================================
  home-manager.users.t0psh31f = {
    desktop.noctalia.backend = "hyprland";
    features.home.agent.opencode = {
      enable = true;
      desktop = true;
    };
    features.home.agent.gemini-cli.enable = true;
    programs.cli-environment.pythonTools.enable = true;
    home-config.antigravity.enable = true;
  };

  # ============================================================================
  # SOPS SECRETS
  # ============================================================================
  sops.age.keyFile = "/home/t0psh31f/.config/sops/age/keys.txt";

  # ============================================================================
  # SECURITY / ACME
  # ============================================================================
  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@grandlix.com";
  };
}
