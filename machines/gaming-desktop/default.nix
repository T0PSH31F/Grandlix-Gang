{
  ...
}: {
  # ============================================================================
  # 00 - CORE IMPORTS
  # ============================================================================
  imports = [
    # REQUIRED: Generate this via `nixos-generate-config` for bare-metal
    # ./hardware.nix

    # Core Layers
    ../../layers/10-system
    ../../layers/20-services
    ../../layers/30-identity/32-themes
    
    # REQUIRED: Add your user identity here
    ../../layers/30-identity/31-users/t0psh31f.nix
  ];

  # ============================================================================
  # 01 - MACHINE IDENTITY
  # ============================================================================
  networking.hostName = "gaming-desktop"; # MUST MATCH DIRECTORY NAME
  system.stateVersion = "25.05"; # Match your flake version

  # ----------------------------------------------------------------------------
  # DEPLOYMENT TYPES & REQUIRED CONFIGURATION
  # ----------------------------------------------------------------------------
  # 1. Bare Metal:
  #    - Generate hardware.nix via `nixos-generate-config`
  #    - Add `disko` if using declarative partitioning
  #
  # 2. Cloud / VPS (e.g. Hetzner, AWS):
  #    - Ensure `profiles/tags/server.nix` is in tags list
  #    - Add SSH keys and fail2ban
  #
  # 3. Containers (LXC/Proxmox):
  #    - Include `../../layers/10-system/12-hardware/lxc.nix` (if exists)
  #    - Do not use `disko`
  # ----------------------------------------------------------------------------

  # ----------------------------------------------------------------------------
  # AVAILABLE PROFILES / TAGS
  # ----------------------------------------------------------------------------
  # Tags define the machine's role and automatically enable corresponding features.
  # Add tags here, but they MUST match what is set in `clan.nix` at the root!
  #
  # Form Factor: "workstation", "desktop", "laptop"
  # Roles:       "server", "development", "gaming", "ai-server", "homelab", "cache-server", "media-server"
  # ----------------------------------------------------------------------------
  machine.tags = [
    "desktop"
    "gaming"
  ];

  # ============================================================================
  # 02 - LAYERED FEATURE FLAGS (Overrides)
  # ============================================================================
  # Note: Most features are automatically enabled via machine.tags -> 90-profiles
  # Only explicitly define features here if:
  # 1. It is highly specific to this exact machine (e.g. Corsair hardware)
  # 2. You need to disable a feature that is normally enabled by a tag (e.g. gui.gaming.enable = false)
  layers = {
    # Example: Override a tag default
    # layer-60.gui.gaming.enable = false; 
    
    # Example: Machine-specific hardware
    # layer-10.system.hardware.openrgb.enable = true;
  };

  # ============================================================================
  # 03 - SERVICE SPECIFICS & OVERRIDES (Layer 20)
  # ============================================================================
  # Note: Most raw services are automatically enabled via machine.tags
  services = {
    # Define custom Caddy routing, DDNS domains, or explicit service toggles here.
  };

  # ============================================================================
  # 04 - SYSTEM & PROGRAM OVERRIDES
  # ============================================================================
  # Advanced config, firewall rules, or specific unfree packages.
  
  # ============================================================================
  # 05 - SECURITY & SECRETS (SOPS/ACME)
  # ============================================================================
  # sops.age.keyFile = "/home/username/.config/sops/age/keys.txt";
}
