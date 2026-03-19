{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.virtualization = {
    enable = mkEnableOption "Virtualization support (QEMU/KVM, Docker, Podman)";
  };

  config = mkIf config.virtualization.enable {
    programs.extra-container = {
      enable = true;
    };

    # Ensure dconf is enabled for virt-manager to save settings
    programs.dconf.enable = true;

    # Add your user to the virtualization group
    users.users.t0psh31f.extraGroups = [
      "libvirtd"
      "kvm"
    ];

    # Enable virtualization
    virtualisation = {
      # Enable libvirtd for QEMU/KVM
      libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          swtpm.enable = true; # Required for Windows 11 TPM emulation
          runAsRoot = false;
          ovmf = {
            enable = true;
            packages = [ pkgs.OVMFFull.fd ]; # UEFI support
          };
        };
      };

      # This enables the SPICE USB redirector daemon
      spiceUSBRedirection.enable = true;

      # Podman configuration (Docker replacement)
      podman = {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        defaultNetwork.settings.dns_enabled = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
      };

      oci-containers.backend = "podman";
    };

    # The GUI to manage the VM
    programs.virt-manager.enable = true;

    # Install virtualization tools
    environment.systemPackages = with pkgs; [
      # QEMU and related tools
      qemu
      quickemu
      quickgui

      # VM management
      virt-viewer
      spice
      spice-gtk
      spice-protocol
      virtio-win
      win-spice

      # Container tools
      #podman-compose
      distrobox
      compose2nix

      # Bridge utilities
      bridge-utils

      # OCI tools
      buildah
      skopeo
      nixos-shell
    ];

    # Persistence for virtualization data
    environment.persistence."/persist" = mkIf config.system-config.impermanence.enable {
      directories = [
        "/var/lib/containers"
        "/var/lib/podman"
        "/var/lib/libvirt"
        "/etc/libvirt"
        "/var/lib/mongodb-container"
      ];
    };
  };
}
