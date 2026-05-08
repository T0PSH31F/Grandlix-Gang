{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-20.services.config.download-clients;
  mediaCfg = config.layers.layer-20.services.config.media-stack;
in
{
  # We still want to keep the options in download-clients.nix or move them here?
  # Let's keep the options in download-clients.nix for now but move the implementation here.
  
  config = mkIf (cfg.enable && cfg.aria2.enable) {
    # ============================================================================
    # ARIA2 - Download Client
    # ============================================================================
    environment.systemPackages = [ 
      pkgs.aria2 
      pkgs.ariang
      pkgs.python3Packages.aria2p
    ];
    
    # Simple static web UI for Aria2
    systemd.services.ariang = {
      description = "AriaNg Web UI";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.python3}/bin/python3 -m http.server 6801 --directory ${pkgs.ariang}/share/ariang";
        DynamicUser = true;
        Restart = "always";
      };
    };

    clan.core.vars.generators.aria2 = {
      files."rpc_secret" = {
        secret = true;
        owner = mediaCfg.user; # Use media user instead of aria2 to be safe
        group = mediaCfg.group;
      };
      prompts."rpc_secret" = {
        type = "hidden";
        description = "Aria2 RPC Secret Token";
      };
      script = ''
        if [ -f "$prompts/rpc_secret" ]; then
          cat "$prompts/rpc_secret" > "$out/rpc_secret"
        else
          echo "Error: Prompt rpc_secret not found" >&2
          exit 1
        fi
      '';
    };

    services.aria2 = {
      enable = true;
      openPorts = true;
      rpcSecretFile = config.clan.core.vars.generators.aria2.files."rpc_secret".path;
      settings = {
        dir = "${mediaCfg.downloadsDir}/aria2";
        enable-rpc = true;
        rpc-listen-port = cfg.aria2.port;
        rpc-listen-all = true;
        max-concurrent-downloads = 5;
        continue = true;
        save-session = "/var/lib/aria2/session.gz";
        input-file = "/var/lib/aria2/session.gz";
        save-session-interval = 60;
      };
    };

    # Ensure aria2 has access to media group
    users.users.aria2 = {
      isSystemUser = true;
      group = mediaCfg.group;
      extraGroups = [ mediaCfg.group ];
    };

    # Directory structures
    systemd.tmpfiles.rules = [
      "d ${mediaCfg.downloadsDir}/aria2 0755 ${mediaCfg.user} ${mediaCfg.group} -"
      "d /var/lib/aria2 0755 aria2 ${mediaCfg.group} -" # Changed to 0755 and aria2 owner
      "f /var/lib/aria2/session.gz 0664 aria2 ${mediaCfg.group} -" # Changed to 0664 and aria2 owner
    ];

    # Firewall
    networking.firewall.allowedTCPPorts = [ cfg.aria2.port 6801 ];

    # Persistence
    environment.persistence."/persist" = mkIf config.layers.layer-10.system.config.impermanence.enable {
      directories = [
        {
          directory = "/var/lib/aria2";
          user = "aria2";
          group = mediaCfg.group;
          mode = "0750";
        }
      ];
    };
  };
}
