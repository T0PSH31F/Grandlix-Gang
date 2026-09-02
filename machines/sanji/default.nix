# sanji — Alibaba Elastic Compute (US West-1, us-west-1b) control plane + gno
# Instance ID : i-rj951wld3zoyv1lr6nk7
# Public IP   : 47.254.90.69
# Private IP  : 172.21.238.38
# SSH key     : id_25519 t0psh31f@ganglib.gang  (~/.ssh/)
#
# Headless server: no desktop user, no display compositor, no agents.
# Memory services stay on luffy for privacy. gno runs here (always-on).
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ ./hardware.nix ];

  machine.tags = [
    "server"
    "homelab"
  ];

  networking.hostName = "sanji";
  system.stateVersion = "25.05";

  # === Privacy-gate: memory services stay on luffy ===
  services.honcho.enable = lib.mkForce false;
  services.ai-services.brain-service.enable = lib.mkForce false;

  # === gno: retrieval/workspace/graph OCI container (always-on, indexes luffy corpus) ===
  layers.layer-20.services.gno = {
    enable = true;
    port = 3456;
    dataDir = "/var/lib/gno";
    corpusDir = "/var/lib/gno/corpus"; # Synced from luffy via rsync/cron
  };

  # === Cloud VM: ext4 root, no tmpfs/impermanence ===
  layers.layer-10.system.config.impermanence.enable = lib.mkForce false;

  # === Home Manager: disable useUserPackages on headless host ===
  # This avoids the XDG portal pathsToLink assertion triggered by the
  # vicinae HM module (imported via hm-catalog.nix for option definition).
  # Portals are irrelevant without a display compositor.
  home-manager.useUserPackages = lib.mkForce false;

  # === SSH (Alibaba security group: public from admin IP only) ===
  # Base layer uses mkForce true; we need mkOverride 0 to win.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = lib.mkOverride 0 false;
      PermitRootLogin = lib.mkOverride 0 "prohibit-password";
    };
  };

  # === Firewall: SSH + gno (locked to Tailscale by SG) ===
  networking.firewall.allowedTCPPorts = [
    22
    3456
  ];

  # === Tailscale/Headscale — configured via server/homelab tags ===
  # Set clan.nix deploy.targetHost to Tailscale IP once joined.

  # === Restic backups ===
  layers.layer-20.services.backups.restic.enable = lib.mkDefault true;
}
