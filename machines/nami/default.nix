{ ... }:
{
  # ============================================================================
  # 00 - CORE IMPORTS
  # ============================================================================
  imports = [
    ./hardware.nix

    ../../layers/10-system
    ../../layers/30-identity/32-themes
    ../../layers/20-services
    ../../layers/30-identity/31-users/t0psh31f.nix
  ];

  # ============================================================================
  # 01 - MACHINE IDENTITY
  # ============================================================================
  networking.hostName = "nami";
  system.stateVersion = "25.05";

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
  machine.tags = [
    "desktop"
    "laptop"
    "media-server"
    "workstation"
    "media"
    "homelab"
  ];

  # ============================================================================
  # 02 - LAYERED FEATURE FLAGS (Overrides)
  # ============================================================================
  # Note: Most features are automatically enabled via machine.tags -> 90-profiles
  layers = {
    layer-10.system = {
      mobile = {
        android.enable = true;
      };
      config.impermanence.enable = true;
      virtualization.enable = true;
    };

    layer-20.services.config = {
      your-spotify.enable = true;
    };

    layer-30.identity.themes = {
      greeter.sddm = {
        enable = true;
        background = ../../layers/00-cyberia/02-assets/sddm_background/the-world-of-one-piece_800.gif;
      };
      grub-lain.efiInstallAsRemovable = true; # Fix for Dell XPS 13 boot registration
    };

    layer-40.desktop = {
      noctalia.backend = "niri";
    };

    layer-60.gui.gaming.enable = false; # Explicitly disabled despite potential tag inheritance
  };

  # ============================================================================
  # 03 - SERVICE SPECIFICS & OVERRIDES (Layer 20)
  # ============================================================================
  # Note: Most raw services are automatically enabled via machine.tags
  services = {
    # Disabled Services (Overrides from homelab tag)
    searxng.enable = false;
    headscale-server.enable = false;
    vaultwarden-server.enable = false;

    # Explicitly Enabled Specific Services
    n8n-server.enable = true;
    komga-server.enable = true;
    mautrix-bridges.enable = true;
  };

  # ============================================================================
  # 05 - SECURITY & SECRETS (SOPS)
  # ============================================================================
  sops.age.keyFile = "/home/t0psh31f/.config/sops/age/keys.txt";
}
