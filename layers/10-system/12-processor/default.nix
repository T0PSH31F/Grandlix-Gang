# Processor and Platform Tier Entry Point
{ ... }:
{
  imports = [
    # Base
    ./12.4-platform/common.nix

    # CPU (Unified Intel)
    ./12.1-cpu/intel.nix

    # GPU (Dedicated Nvidia)
    ./12.2-gpu/nvidia.nix

    # Device & Platform (Audio, Laptop)
    ./12.4-platform/audio.nix
    ./12.4-platform/laptop.nix
  ];

}
