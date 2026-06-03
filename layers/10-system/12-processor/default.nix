# Processor and Platform Tier Entry Point
{ ... }:
{
  imports = [
    # Base
    ./12.4-platform/common.nix

    # Consolidated Intel CPU/GPU
    ./12.1-cpu/intel.nix

    # Other GPUs
    ./12.2-gpu/nvidia-hybrid.nix
    ./12.2-gpu/nvidia.nix

    # Device & Platform (Audio, Laptop)
    ./12.4-platform/audio.nix
    ./12.4-platform/laptop.nix
  ];
}
