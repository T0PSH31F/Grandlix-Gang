# machines/nami/default.nix
# Main configuration for Nami
# Intel i7-7560U laptop, secondary machine
{ ... }:
{
  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    # Hardware configuration (filesystems, kernel modules)
    ./hardware.nix

    # Core system modules from flake-parts
    ../../flake-parts/system
    ../../flake-parts/hardware
    ../../flake-parts/themes
    ../../flake-parts/features/nixos
    ../../flake-parts/services/media
    ../../flake-parts/services/infrastructure
    ../../flake-parts/services/communication
    ../../flake-parts/services/ai

    # User configuration (HM + user-specific system settings)
    ../../flake-parts/users/t0psh31f.nix
  ];

  services-config.tailscale.enable = true;

  # ============================================================================
  # MACHINE METADATA
  # ============================================================================
  networking.hostName = "nami";
  system.stateVersion = "25.05";
  machine.tags = [
    "desktop"
    "laptop"
    "media-server"
  ];

  # ============================================================================
  # FEATURE TOGGLES
  # ============================================================================

  # System features
  nix-tools.enable = true;
  desktop-portals.enable = true;

  # Themes - match z0r0 for consistency
  themes = {
    greeter = {
      sddm = {
        enable = true;
        background = ../../assets/sddm_background/the-world-of-one-piece_800.gif;
      };
      greetd.enable = false;
    };

    grub-lain = {
      enable = true;
      efiInstallAsRemovable = true; # Fix for Dell XPS 13 boot registration
    };
    plymouth-hellonavi.enable = true;
  };

  # Mobile device support
  mobile = {
    android.enable = true;
    ios.enable = false;
  };

  # Gaming & Virtualization
  gaming.enable = false;
  virtualization.enable = true;

  # Flatpak & AppImage
  flatpak.enable = true;

  # Impermanence - disabled for initial install, enable later once stable
  system-config.impermanence.enable = true;

  # Resource limits enabled for stabilization
  system-config.resource-limits.enable = true;

  # ============================================================================
  # SERVICES
  # ============================================================================
  services = {
    # Desktop Services
    ssh-agent.enable = true;
    searxng.enable = false;
    pastebin.enable = false;

    # Home Automation & Infrastructure
    home-assistant-server.enable = true;
    caddy-server.enable = false;
    n8n-server.enable = true;

    # AI Services - Granular toggles (Keeping these on z0r0 usually)
    llm-agents.enable = false;
    sillytavern.enable = false;
    ai-services = {
      enable = false;
      open-webui.enable = false;
      localai.enable = false;
      chromadb.enable = false;
      qdrant.enable = false;
      lmstudio.enable = false;
      jan.enable = false;
      cherry-studio.enable = false;
      aider.enable = false;
    };

    # Media & Cloud - Offloaded from z0r0
    immich-server.enable = false;
    calibre-web-app.enable = false; # TODO: re-enable when calibre build is fixed in nixpkgs (qmake missing)
    nextcloud-server.enable = false;
    komga-server.enable = true;

    # Communication - Offloaded from z0r0
    matrix-server.enable = false;
    mautrix-bridges.enable = true;

    # Extra Services
    glances-server.enable = true;
    filebrowser-app.enable = true;
    deluge-server.enable = false;
    transmission-server.enable = false;
    headscale-server.enable = false;
  };

  # ============================================================================
  # SERVICES-CONFIG
  # ============================================================================
  services-config = {
    adguard.enable = false; # Added explicit toggle
    media-stack.enable = true; # Toggle for *arr suite
    karakeep.enable = false;
    your-spotify.enable = true;
    avahi.enable = true; # mDNS
    monitoring.enable = true;
    homepage-dashboard.enable = false;
    homepage-dashboard.lovable.enable = false;
  };

  # ============================================================================
  # SOPS SECRETS
  # ============================================================================
  sops.age.keyFile = "/home/t0psh31f/.config/sops/age/keys.txt";
}
