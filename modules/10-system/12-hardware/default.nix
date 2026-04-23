# flake-parts/hardware/default.nix
# Hardware support modules
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

    # Peripheral (Audio, Bluetooth, Controller)
    ./12.4-platform/audio.nix
    ./12.3-peripherals/bluetooth.nix
    ./12.3-peripherals/razer.nix

    # Device (Desktop, Laptop, Touchscreen)
    ./12.4-platform/laptop.nix
    ./12.3-peripherals/touchpad.nix
  ];
}
