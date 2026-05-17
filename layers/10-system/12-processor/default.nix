# Processor and Platform Tier Entry Point
{ ... }:
{
  imports = [
    # Base
    ./12.4-platform/common.nix

    # CPU (Intel or AMD)
    ./12.2-gpu/amd.nix
    ./12.1-cpu/intel-12th-gen.nix
    ./12.1-cpu/intel-7th-gen.nix
    ./12.1-cpu/intel.nix

    # GPU (AMD, Intel, Nvidia)
    ./12.2-gpu/nvidia-hybrid.nix
    ./12.2-gpu/nvidia.nix

    # Device & Platform (Audio, Laptop)
    ./12.4-platform/audio.nix
    ./12.4-platform/laptop.nix
  ];
}
