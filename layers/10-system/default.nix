# System Tier Entry Point
{ ... }: {
  imports = [
    ./11-foundation
    ./12-processor
    ./13-users
    ./14-virtualization/virtualization.nix
    ./15-filesystem/impermanence.nix
    ./15-filesystem/google-drive.nix
    ./16-mobile
    ./17-app-runtimes/appimage.nix
    ./17-app-runtimes/flatpak.nix
    ./18-peripherals
    ./19-optimizations
  ];
}
