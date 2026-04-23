# flake-parts/features/nixos/default.nix
# NixOS feature toggles - optional system functionality
{
  imports = [
    ./17-app-runtimes/appimage.nix
    ./desktop
    ./17-app-runtimes/flatpak.nix
    ./13-packages/gaming.nix
    ./15-storage/impermanence.nix
    ./16-mobile/mobile-support.nix
    ./13-packages
    ./14-virtualization/virtualization.nix
  ];
}
