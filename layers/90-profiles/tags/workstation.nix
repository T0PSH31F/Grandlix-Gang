{ lib, ... }: {
  imports = [
    ../../10-system
    ../../20-services
    ../../30-identity
    ../../40-desktop
    ../../50-cli-tui-programs
    ../../60-gui-programs
    ../../70-agents
  ];

  features = {
    system.config.resource-limits.enable = lib.mkDefault true;
    cli.nixTools.enable = lib.mkDefault true;
    identity.themes = {
      grub-lain.enable = lib.mkDefault true;
      plymouth-hellonavi.enable = lib.mkDefault true;
    };
    services.config = {
      avahi.enable = lib.mkDefault true;
      tailscale.enable = lib.mkDefault true;
      monitoring.enable = lib.mkDefault true;
    };
  };

  services.ssh-agent.enable = lib.mkDefault true;
}
