# flake-parts/users/t0psh31f.nix
{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # System-level user settings not managed by Clan
  users.users.t0psh31f = {
    isNormalUser = true;
    description = "t0psh31f";
    shell = pkgs.zsh;
    hashedPassword = "$6$VRNKFZO5ZSa8uxSa$LFncLEfnLcQrIvOFJba89yRqxxavrJtuaDrO1O6Ods3uG8csVxCUpiHMQN1cwxgO/hIERux6PTAJIDYwdj77S/";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "input"
      "podman"
      "libvirtd"
      "media"
      "podman"
      "i2c"
    ];
    # Authorized keys are also managed by clan-inventory.nix (admin-access),
    # but we keep them here for local login consistency.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJrQr8qxQTw45PNpsDNahVE23tpV3Zap+IKr6eVkL75Z t0psh31f@grandlix.gang"
    ];
  };

  users.users.t0psh31f.hashedPasswordFile = lib.mkForce null;

  # Home Manager configuration for t0psh31f
  # Permanent fix for backup collisions: Automatically remove old backups before activation
  home-manager.backupFileExtension = "hm-backup";
  home-manager.backupCommand = "${pkgs.writeShellScript "hm-backup-cleanup" ''
    set -eu
    # Use the extension defined in backupFileExtension
    EXT="hm-backup"
    FILE="$1"
    BACKUP="$FILE.$EXT"

    # If a backup already exists, remove it so HM can create a new one
    if [ -e "$BACKUP" ]; then
      rm -rf "$BACKUP"
    fi
  ''}";
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.t0psh31f =
    { config, ... }:
    {
      imports = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.vicinae.homeManagerModules.default
        ../features/home
      ];

      sops.age.keyFile = "/home/t0psh31f/.config/sops/age/keys.txt";

      sops.secrets.git_name = {
        sopsFile = ../../treasure/secrets/git.yaml;
        format = "yaml";
      };
      sops.secrets.git_email = {
        sopsFile = ../../treasure/secrets/git.yaml;
        format = "yaml";
      };

      # Vicinae secrets (API keys, tokens, etc.)
      sops.secrets."vicinae.json" = {
        sopsFile = ../../treasure/secrets/vicinae.yaml;
        format = "yaml";
      };

      # AI/LLM API Keys
      sops.secrets.gemini_api_key = {
        sopsFile = ../../treasure/secrets/vicinae.yaml;
        format = "yaml";
      };
      sops.secrets.openrouter_api_key = {
        sopsFile = ../../treasure/secrets/vicinae.yaml;
        format = "yaml";
      };

      sops.templates."git-config".content = ''
        [user]
          name = ${config.sops.secrets.git_name.path}
          email = ${config.sops.secrets.git_email.path}
      '';

      # Export API keys as environment variables
      home.sessionVariables = {
        GEMINI_API_KEY = "$(cat ${config.sops.secrets.gemini_api_key.path})";
        OPENROUTER_API_KEY = "$(cat ${config.sops.secrets.openrouter_api_key.path})";
      };

      home.stateVersion = "25.05";
      home.username = "t0psh31f";
      home.homeDirectory = "/home/t0psh31f";

      home.packages = with pkgs; [
        nextcloud-client
        nextcloud-talk-desktop
        spacedrive
      ];

      # Enable the new CLI environment
      programs.cli-environment.enable = true;

      # Enable Documents & Publishing suite
      home-config.documents.enable = true;

      # Enable Yazelix inside Home Manager scope
      features.home.cli.yazelix.enable = true;
    };

}
