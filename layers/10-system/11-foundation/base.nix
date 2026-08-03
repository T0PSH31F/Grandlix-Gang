{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  # ============================================================================
  # GLOBAL SETTINGS
  # ============================================================================
  users.mutableUsers = false;

  # Workaround for nixpkgs unstable broken symlinks in util-linux.bin
  security.wrappers.mount.source = lib.mkForce "${pkgs.util-linuxMinimal}/bin/mount";
  security.wrappers.umount.source = lib.mkForce "${pkgs.util-linuxMinimal}/bin/umount";

  # Enable experimental features
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
  ];

  _module.args.osConfig = config;

  _module.args.lib = lib.extend (
    final: prev: {
      hm = inputs.home-manager.lib.hm;
    }
  );

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
    };
  };

  # ============================================================================
  # SYSTEM CORE CONFIGURATION
  # ============================================================================
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "beekeeper-studio-5.5.7"
    "olm-3.2.16"
    "nodejs-20.20.2"
    "nodejs-slim-20.20.2"
    "webull-desktop-9.3.0"
    "electron-40.10.5"
    "pnpm-10.29.2"
  ];

  # Bootloader
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10; # Increased for more rollback room
      };
      efi.canTouchEfiVariables = true;
    };

    blacklistedKernelModules = [
      "8250"
      "8250_pci"
      "serial_core"
    ];
    initrd = {
      systemd.enable = true;
      compressor = "zstd";
    };
  };

  # Locale & Time
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  documentation = {
    enable = false;
    nixos.enable = false;
    man.enable = false;
    info.enable = false;
    doc.enable = false;
  };

  # ============================================================================
  # PACKAGES & TOOLS (Minimal System-level)
  # ============================================================================
  environment.systemPackages = with pkgs; [
    # Boot/System essentials
    curl
    git
    vim
    wget
    ghostty.terminfo
  ];

  programs.zsh.enable = true;

  # Bypass broken check-sshd-config.drv / sandbox PAM link error by disabling build-time system checks
  system.checks = lib.mkForce [ ];

  # Root password from secrets
  # Fallback root password - change immediately after first login with `passwd`
  users.users.root = {
    hashedPassword = "$6$VRNKFZO5ZSa8uxSa$LFncLEfnLcQrIvOFJba89yRqxxavrJtuaDrO1O6Ods3uG8csVxCUpiHMQN1cwxgO/hIERux6PTAJIDYwdj77S/";
    hashedPasswordFile = lib.mkForce null;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519AAAAC3NzaC1lZDI1NTE5AAAAIJrQr8qxQTw45PNpsDNahVE23tpV3Zap+IKr6eVkL75Z t0psh31f@grandlix.gang"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDg4e32XqA2CyYsHyl+urGN1Soiz00DLgc+dkDw/uFCw luffy@agentaflow.com"
    ];
  };
}
