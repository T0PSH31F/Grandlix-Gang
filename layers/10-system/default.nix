{ ... }: {
  imports = [
    ./11-foundation
    ./12-hardware
    ./13-packages
    ./14-virtualization/virtualization.nix
    ./15-storage/impermanence.nix
    ./16-mobile/mobile-support.nix
    ./17-app-runtimes/appimage.nix
    ./17-app-runtimes/flatpak.nix
    ./18-ai-infra/ai-agent-stack.nix
  ];
}
