# sanji — Alibaba Elastic Compute (US West-1, us-west-1b) control plane + gno
# Instance ID : i-rj951wld3zoyv1lr6nk7
# Public IP   : 47.254.90.69
# Private IP  : 172.21.238.38
# SSH key     : id_25519 t0psh31f@ganglib.gang  (~/.ssh/)
#
# Roles: network-router (Headscale, Homepage), ai-router (Kong, Omniroute),
#        agent-orchestrator (Hermes, Mission Control, Paperclip).
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

  networking.hostName = "sanji";
  system.stateVersion = "25.05";

  # === Headscale — fleet VPN control server (via network-router tag) ===
  services.headscale-server = {
    serverUrl = "https://headscale.lovelain.duckdns.org";
    # Update the above to Sanji's public IP/domain once DNS is pointed here.
  };

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
  home-manager.useUserPackages = lib.mkForce false;

  # === SSH (Alibaba security group: public from admin IP only) ===
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = lib.mkOverride 0 false;
      PermitRootLogin = lib.mkOverride 0 "prohibit-password";
    };
  };

  # === Firewall: SSH + gno + headscale + HTTPS ===
  networking.firewall.allowedTCPPorts = [
    22
    80 # Caddy HTTP (ACME challenges)
    443 # Caddy HTTPS (Headscale, Homepage)
    3456 # gno
  ];

  # === Restic backups ===
  layers.layer-20.services.backups.restic.enable = lib.mkDefault true;
}
