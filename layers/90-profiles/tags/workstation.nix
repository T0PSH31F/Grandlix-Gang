{ lib, ... }:
{
  imports = [
    ../../10-system
    ../../20-services
    ../../30-theming
    ../../40-desktop
    ../../50-cli-tui-programs
    ../../60-gui-programs
    ../../70-agents
  ];

  layers = {
    layer-10.system.config.resource-limits.enable = lib.mkDefault true;
    layer-50.cli.nixTools.enable = lib.mkDefault true;
    layer-30.theming.themes = {
      grub-lain.enable = lib.mkDefault false;
      plymouth-hellonavi.enable = lib.mkDefault false;
    };
    layer-20.services.config = {
      avahi.enable = lib.mkDefault true;
      tailscale.enable = lib.mkDefault true;
      monitoring.enable = lib.mkDefault true;
    };
  };

  services.ssh-agent.enable = lib.mkDefault true;
}
