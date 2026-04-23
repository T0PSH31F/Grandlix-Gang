# flake-parts/users/t0psh31f.nix
{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  programs = {
    zsh.enable = true;
  };

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
        ../../50-cli-tui-programs/50-entry/default.nix
        ../../60-gui-programs/default.nix
        ../../70-agents/default.nix
      ];

      sops.age.keyFile = "/home/t0psh31f/.config/sops/age/keys.txt";

      sops.secrets.git_name = {
        sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/git.yaml;
        format = "yaml";
      };
      sops.secrets.git_email = {
        sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/git.yaml;
        format = "yaml";
      };

      # Vicinae secrets (API keys, tokens, etc.)
      sops.secrets."vicinae.json" = {
        sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/vicinae.yaml;
        format = "yaml";
      };

      # AI/LLM API Keys
      sops.secrets.gemini_api_key = {
        sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/vicinae.yaml;
        format = "yaml";
      };
      sops.secrets.openrouter_api_key = {
        sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/vicinae.yaml;
        format = "yaml";
      };

      # External Services Secrets
      sops.secrets.server_root_password = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.spacedrive_key = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.openclaw_gateway_token = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.gemini_api_key_lovelain = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.gemini_api_key_we77 = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.openrouter_api_key_1 = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.openrouter_api_key_2 = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.openrouter_api_key_3 = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.groq_api_key = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.reka_api_key = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.cerebras_api_key = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.ai21_api_key = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.cohere_api_key = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.hf_token = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.jules_api_key_ll = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.v0_api_key_we77 = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.github_models_api = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.helius_api_key = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.helius_rpc_url = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.solsniper_x_api_consumer_key = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.solsniper_x_api_secret_key = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.solsniper_x_api_bearer_token = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.solsniper_x_api_client_id = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.solsniper_x_api_client_secret = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.supabase_password = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.supabase_api_key = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.lovelain_api_key_ext = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; key = "lovelain_api_key"; };
      sops.secrets.neon_postgres_api = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.cloudflare_workers_api_we77 = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.cloudflare_workers_api_lovelain = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.cloudflare_workers_api_lovelain_full = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.cloudflare_access_id = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.scaleway_gh_access_key = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.scaleway_gh_secret_key = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.scaleway_gh_org_id = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.scaleway_gh_project_id = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.render_api_we77 = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.apify_api_we77 = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.google_stitch_api_we77 = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.tinybird_api_gh = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.tinybird_mcp_gh = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.nexsos_api = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.hostinger_api_token_ext = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; key = "hostinger_api_token"; };
      sops.secrets.qdrant_api = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.google_oauth_lovelain_client_id = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.google_oauth_lovelain_client_secret = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.opencode_token = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.grafana_pass = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.beszel_lovelain_pass = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.maxkb_pass = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.browser_use_api = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.context7_api_we77 = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      sops.secrets.tg_botfather_http = { sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml; };
      # TODO: Add rclone_config key to external_services.yaml before enabling
      # sops.secrets.rclone_config = {
      #   sopsFile = ../../../layers/00-cyberia/03-treasure/secrets/external_services.yaml;
      #   path = "${config.home.homeDirectory}/.config/rclone/rclone.conf";
      # };

      sops.templates."git-config".content = ''
        [user]
          name = ${config.sops.secrets.git_name.path}
          email = ${config.sops.secrets.git_email.path}
      '';

      # Global .env file on Desktop for projects
      sops.templates."desktop-env" = {
        path = "${config.home.homeDirectory}/Desktop/.env";
        content = ''
          SERVER_ROOT_PASSWORD=${config.sops.placeholder.server_root_password}
          SPACEDRIVE_KEY=${config.sops.placeholder.spacedrive_key}
          OPENCLAW_GATEWAY_TOKEN=${config.sops.placeholder.openclaw_gateway_token}
          
          # AI Services
          GEMINI_API_KEY_LOVELAIN=${config.sops.placeholder.gemini_api_key_lovelain}
          GEMINI_API_KEY_WE77=${config.sops.placeholder.gemini_api_key_we77}
          OPENROUTER_API_KEY_1=${config.sops.placeholder.openrouter_api_key_1}
          OPENROUTER_API_KEY_2=${config.sops.placeholder.openrouter_api_key_2}
          OPENROUTER_API_KEY_3=${config.sops.placeholder.openrouter_api_key_3}
          GROQ_API_KEY=${config.sops.placeholder.groq_api_key}
          REKA_API_KEY=${config.sops.placeholder.reka_api_key}
          CEREBRAS_API_KEY=${config.sops.placeholder.cerebras_api_key}
          AI21_API_KEY=${config.sops.placeholder.ai21_api_key}
          COHERE_API_KEY=${config.sops.placeholder.cohere_api_key}
          HF_TOKEN=${config.sops.placeholder.hf_token}
          JULES_API_KEY_LL=${config.sops.placeholder.jules_api_key_ll}
          V0_API_KEY_WE=${config.sops.placeholder.v0_api_key_we77}
          GITHUB_MODELS_API=${config.sops.placeholder.github_models_api}
          
          # Infrastructure & Cloud
          HELIUS_API_KEY=${config.sops.placeholder.helius_api_key}
          SUPABASE_API_KEY=${config.sops.placeholder.supabase_api_key}
          CLOUDFLARE_ACCESS_ID=${config.sops.placeholder.cloudflare_access_id}
          CLOUDFLARE_LOVELAIN_WORKERS=${config.sops.placeholder.cloudflare_workers_api_lovelain}
          CLOUDFLARE_WE77_WORKERS=${config.sops.placeholder.cloudflare_workers_api_we77}
          SCW_GH_ACCESS_KEY=${config.sops.placeholder.scaleway_gh_access_key}
          SCW_GH_SECRET_KEY=${config.sops.placeholder.scaleway_gh_secret_key}
          RENDER_API_WE=${config.sops.placeholder.render_api_we77}
          APIFY_API_WE77=${config.sops.placeholder.apify_api_we77}
          TINYBIRD_API_GH=${config.sops.placeholder.tinybird_api_gh}
          STITCH_API_WE77=${config.sops.placeholder.google_stitch_api_we77}
          CONTEXT7_API_WE=${config.sops.placeholder.context7_api_we77}
          HOSTINGER_API_TOKEN=${config.sops.placeholder.hostinger_api_token_ext}
          QDRANT_API=${config.sops.placeholder.qdrant_api}
        '';
      };

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
      features.home.cli.services.rclone.enable = true;

      # Envoluntary configuration
      home.file.".config/envoluntary/config.toml".text = ''
        [[entries]]
        pattern = ".*/Clan/NFP(/.*)?"
        flake_reference = "path:${config.home.homeDirectory}/Clan/NFP"

        [[entries]]
        pattern = ".*/Projects/n8n-sorting-nix(/.*)?"
        flake_reference = "path:${config.home.homeDirectory}/Projects/n8n-sorting-nix"

        [[entries]]
        pattern = ".*/Projects/python(/.*)?"
        flake_reference = "nixpkgs#python313"

        [[entries]]
        pattern = ".*/Projects/typescript(/.*)?|.*/Projects/node(/.*)?"
        flake_reference = "nixpkgs#nodejs_22"

        [[entries]]
        pattern = ".*/Projects/rust(/.*)?"
        flake_reference = "nixpkgs#rustc"

        [[entries]]
        pattern = ".*/Projects/go(/.*)?"
        flake_reference = "nixpkgs#go"

        [[entries]]
        pattern = ".*/Projects/php(/.*)?"
        flake_reference = "nixpkgs#php"

        [[entries]]
        pattern = ".*/Projects/ruby(/.*)?"
        flake_reference = "nixpkgs#ruby"

        [[entries]]
        pattern = ".*/Projects/ocaml(/.*)?"
        flake_reference = "nixpkgs#ocaml"

        [[entries]]
        pattern = ".*/Projects/latex(/.*)?"
        flake_reference = "nixpkgs#texlive.combined.scheme-full"

        [[entries]]
        pattern = ".*/Projects/markdown(/.*)?|.*/Projects/docs(/.*)?"
        flake_reference = "nixpkgs#nix-shell"

        [[entries]]
        pattern = ".*/Projects(/.*)?"
        flake_reference = "nixpkgs#nix-shell"
      '';
    };

}
