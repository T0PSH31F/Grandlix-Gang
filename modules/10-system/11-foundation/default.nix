# flake-parts/system/default.nix
# Core system modules - foundational configuration for all machines
{
  imports = [
    ./ai-agent-stack.nix
    ./base.nix
    ./caches.nix
    ./clan-lib.nix
    ./fonts.nix
    ./networking.nix
    ./nix-settings.nix
    ./nix-tools.nix
    ./optimization.nix
    ./overlays.nix
    ./resource-limits.nix
  ];
}
