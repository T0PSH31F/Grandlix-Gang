{
  config,
  lib,
  inputs,
  ...
}:
with lib;
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options.layers.layer-10.system.config.impermanence = {
    enable = mkEnableOption "NixOS impermanence (ephemeral root)";

    persistPath = mkOption {
      type = types.str;
      default = "/persist";
      description = "Path to persistent storage";
    };
  };

  config = mkIf config.layers.layer-10.system.config.impermanence.enable {
    # ============================================================================
    # ENVIRONMENT PERSISTENCE
    # ============================================================================
    environment.persistence.${config.layers.layer-10.system.config.impermanence.persistPath} = {
      hideMounts = true;

      directories = [
        # System directories
        "/var/lib/systemd"
        "/var/lib/nixos"
        "/var/log"

        # Network configuration
        "/etc/NetworkManager/system-connections"

        # SSH host keys
        "/etc/ssh"
      ];

      files = [
        # Machine identity
        "/etc/machine-id"

        # SOPS age key (generated automatically from ssh keys)
        # User and group database files
        # "/etc/passwd"
        # "/etc/shadow"
        # "/etc/group"
      ];

      # Per-user persistence
      users.t0psh31f = {
        directories = [
          # Projects and work
          "Clan"
          "Projects"
          "projects"
          "Documents"
          "Downloads"
          "Pictures"
          "Videos"
          "Music"

          # Configuration
          ".config"
          ".local"

          # SSH & GPG
          ".ssh"
          ".gnupg"

          # Development caches
          ".cache"

          # Browser profiles (if needed)
          ".mozilla"
          ".config/chromium"
          ".config/BraveSoftware"

          # VS Code / editors
          ".vscode"
          ".config/Code"

          # Shell history & state
          ".local/share/fish"
          ".local/share/zsh"

          # Legacy/Custom User Data (Preserved)
          "Agents"
          "NixOS"
          "Public"
          "Templates"
          "Games"
          "Flatpaks"
          "Appimages"
          "Notes"
          ".icons"
          ".themes"
          ".cursors"
          ".pki"
          ".thunderbird"
          ".background"
#           ".antigravity"
          ".gemini"
          ".hermes"
          ".kodi"
          ".var/app"
        ];

        files = [
          # Shell history
          ".bash_history"
          ".zsh_history"

          # facter.json
          "facter.json"
        ];
      };
    };

    # Ensure proper permissions for service directories
    # Only create directories for services that are actually enabled on this machine
    systemd.tmpfiles.rules = [
      # Core persistence directory
      "d ${config.layers.layer-10.system.config.impermanence.persistPath} 0755 root root -"
      "d ${config.layers.layer-10.system.config.impermanence.persistPath}/etc 0755 root root -"
      "d ${config.layers.layer-10.system.config.impermanence.persistPath}/etc/ssh 0755 root root -"

      # User home persistence
      "d /persist/home/t0psh31f 0700 t0psh31f users"
      "d /persist/home/t0psh31f/.ssh 0700 t0psh31f users"
      "d /persist/home/t0psh31f/.gnupg 0700 t0psh31f users"

    ];

    # ============================================================================
    # BTRFS ROOT & HOME WITH SNAPSHOT ROLLBACK
    # ============================================================================
    # Both / and /home are handled by disko.nix (@root and @home subvolumes)
    # The postDeviceCommands below will roll them back on each boot
    # This provides full impermanence (determinate builds)

    # Btrfs snapshot rollback for impermanence (Systemd Initrd Version)
    boot.initrd.systemd.services.rollback = {
      description = "Rollback BTRFS root and home snapshots";
      wantedBy = [ "initrd.target" ];
      after = [ "initrd-root-device.target" ];
      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /mnt
        mount -t btrfs -o subvol=/ ${config.fileSystems."/".device} /mnt

        # Function to delete subvolume recursively
        delete_subvolume_recursively() {
          local subvol=$1
          # List all child subvolumes
          # 'btrfs subvolume list -o' lists subvolumes below the given path
          for child in $(btrfs subvolume list -o "$subvol" | cut -f 9- -d ' ' | tac); do
            btrfs subvolume delete "/mnt/$child"
          done
          btrfs subvolume delete "/mnt/$subvol"
        }

        # Rollback @root
        if [[ -e /mnt/@root ]]; then
            if [[ ! -e /mnt/@root-blank ]]; then
                btrfs subvolume snapshot -r /mnt/@root /mnt/@root-blank
            fi
            delete_subvolume_recursively "@root"
        fi
        btrfs subvolume snapshot /mnt/@root-blank /mnt/@root

        # Rollback @home
        if [[ -e /mnt/@home ]]; then
            if [[ ! -e /mnt/@home-blank ]]; then
                btrfs subvolume snapshot -r /mnt/@home /mnt/@home-blank
            fi
            delete_subvolume_recursively "@home"
        fi
        btrfs subvolume snapshot /mnt/@home-blank /mnt/@home

        umount /mnt
      '';
    };

    # ============================================================================
    # ADDITIONAL CONFIGURATION
    # ============================================================================
    # Mark persistent storage as needed for boot
    fileSystems."/persist".neededForBoot = true;
    fileSystems."/var/log".neededForBoot = true;
    fileSystems."/home".neededForBoot = true;

    # Activation script to ensure persistence dirs exist with correct permissions
    system.activationScripts.ensurePersistenceDirs = {
      text = ''
        mkdir -p /persist/home/t0psh31f/.local/share/noctalia
        mkdir -p /persist/home/t0psh31f/.cache/noctalia
        chown -R t0psh31f:users /persist/home/t0psh31f/.local/share 2>/dev/null || true
        chown -R t0psh31f:users /persist/home/t0psh31f/.cache 2>/dev/null || true
      '';
      deps = [ ];
    };
  };
}
