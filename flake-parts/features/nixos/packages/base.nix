# flake-parts/features/nixos/packages/base.nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Archive tools
    gnutar
    p7zip
    file-roller
    unrar
    unzip
    zip

    # Core system utilities
    coreutils
    fd
    file
    gotree
    jq
    lsof
    pciutils
    procps
    psmisc
    ripgrep
    starship
    tmux
    tree
    usbutils
    util-linux
    which

    # Development basics
    git # (Installed via gitFull in dev-packages or other suites)

    # Disk management
    btrfs-progs
    exfatprogs
    gparted
    parted

    # Document & Image utilities
    imagemagick
    img2pdf
    poppler-utils
    qpdf

    # Isolation
    bubblewrap

    # Network tools
    aria2
    curl
    rsync
    wget

    # Security & Secrets
    age
    gnupg
    sops
  ];

  # Enable nix-ld for running non-NixOS binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
  ];

  programs.starship.enable = true;
}
