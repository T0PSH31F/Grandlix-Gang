{
  config,
  lib,
  ...
}: {
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
  networking.hostName = "z0r0";
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
    "ai-server"
    "build-server"
    "binary-cache"
    "database"
    "dev"
    "media-server"
    "homelab"
    "media"
  ];

  # ============================================================================
  # 02 - LAYERED FEATURE FLAGS (Overrides)
  # ============================================================================
  # Note: Most features are automatically enabled via machine.tags -> 90-profiles
  layers = {
    layer-10.system = {
      hardware.corsair.enable = true;
      hardware.openrgb.enable = true;
      mobile.android.enable = true;
      config.impermanence.enable = true;
      virtualization.enable = true;
    };

    layer-20.services.config = {
      adguard.enable = true;
    };

    layer-30.identity.themes = {
      greeter.greetd = {
        enable = true;
        background = ../../layers/00-cyberia/02-assets/sddm_background/roronoa-zoro_800.gif;
      };
    };

    layer-40.desktop = {
      noctalia.backend = "hyprland";
    };
  };

  # ============================================================================
  # 03 - SERVICE SPECIFICS & OVERRIDES (Layer 20)
  # ============================================================================
  # Note: Most raw services are automatically enabled via machine.tags
  services = {
    # Advanced Service Configuration
    ddclient = {
      enable = true;
      domains = [ "lovelain.duckdns.org" "t0psh31f.duckdns.org" "nixfp.duckdns.org" ];
      protocol = "duckdns";
      passwordFile = config.sops.secrets."duckdns-token".path;
    };

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
  };

  # ============================================================================
  # 04 - SYSTEM & PROGRAM OVERRIDES
  # ============================================================================
  programs.niri.enable = lib.mkForce false;

  # ============================================================================
  # 05 - SECURITY & SECRETS (SOPS/ACME)
  # ============================================================================
  sops = {
    age.keyFile = "/home/t0psh31f/.config/sops/age/keys.txt";
    secrets."duckdns-token" = {
      sopsFile = lib.mkForce ../../layers/00-cyberia/03-treasure/secrets/duckdns.yaml;
      format = lib.mkForce "yaml";
    };
    templates."duckdns-env".content = ''
      DUCKDNS_TOKEN=${config.sops.placeholder."duckdns-token"}
    '';
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@lovelain.duckdns.org";
    certs."lovelain.duckdns.org" = {
      domain = "*.lovelain.duckdns.org";
      extraDomainNames = [ "lovelain.duckdns.org" "t0psh31f.duckdns.org" "nixfp.duckdns.org" ];
      dnsProvider = "duckdns";
      environmentFile = config.sops.templates."duckdns-env".path;
    };
  };
}
