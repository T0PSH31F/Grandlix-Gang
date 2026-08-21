# AionUi — AI agent Cowork web UI
# https://github.com/iOfficeAI/AionUi
#
# TODO: Migrate option namespace services.ai-services.aionui to layers.layer-20.services.aionui
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.aionui;
  primaryUser = config.layers.meta.primaryUser or "t0psh31f";
  version = "2.1.41";

  aionuiPkg = pkgs.stdenv.mkDerivation {
    pname = "aionui-web";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/iOfficeAI/AionUi/releases/download/v${version}/aionui-web-${version}-linux-x86_64.tar.gz";
      hash = "sha256-eXYzrDCzj3sFNVXZ01YDAf2uwlCoGAPy7Xg85PVitXE=";
    };

    sourceRoot = ".";
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/share/aionui
      cp -r aionui-web/* $out/share/aionui/
      chmod +x $out/share/aionui/aionui-web
      ln -s $out/share/aionui/aionui-web $out/bin/aionui-web
      runHook postInstall
    '';

    passthru.updateScript = pkgs.nix-update;

    meta = with lib; {
      description = "Free, open-source Cowork app with AI Agents";
      homepage = "https://github.com/iOfficeAI/AionUi";
      license = licenses.asl20;
      mainProgram = "aionui-web";
    };
  };
in
{
  options.services.ai-services.aionui = {
    enable = mkEnableOption "AionUi — AI agent Cowork web UI";

    port = mkOption {
      type = types.port;
      default = 3006;
      description = "Port for AionUi web UI (3000 conflicts with mission-control, 3001 conflicts with FreeLLMAPI)";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/aionui";
      description = "Persistent data directory";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open the port in the firewall";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion =
          !(config.fileSystems."/"?fsType && config.fileSystems."/".fsType == "tmpfs")
          || (config.layers.layer-10.system.config.impermanence.enable or false);
        message = "services.ai-services.aionui requires impermanence to be enabled (config.layers.layer-10.system.config.impermanence.enable = true) on machines with tmpfs root to prevent credential loss on reboot.";
      }
    ];

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 ${primaryUser} users -"
    ];

    systemd.services.aionui = {
      description = "AionUi — AI agent Cowork web UI";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = primaryUser;
        Group = "users";
        ExecStart = "${lib.getExe aionuiPkg}";
        Restart = "always";
        RestartSec = 5;
        Environment = [
          "HOME=/home/${primaryUser}"
          "PATH=/etc/profiles/per-user/${primaryUser}/bin:/home/${primaryUser}/.nix-profile/bin:/run/current-system/sw/bin"
          "AIONUI_HOST=127.0.0.1"
          "HOST=127.0.0.1"
          "AIONUI_PORT=${toString cfg.port}"
          "PORT=${toString cfg.port}"
          "NODE_ENV=production"
          "AIONUI_DATA_DIR=${cfg.dataDir}"
          "DATA_DIR=${cfg.dataDir}"
          "AIONUI_OPEN_BROWSER=false"
        ];
        WorkingDirectory = "${cfg.dataDir}";
        ReadWritePaths = [
          cfg.dataDir
          "/home/${primaryUser}/.claude"
          "/home/${primaryUser}/.codex"
          "/home/${primaryUser}/.gemini"
          "/home/${primaryUser}/.opencode"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    environment.persistence."/persist" =
      mkIf (config.layers.layer-10.system.config.impermanence.enable or false)
        {
          directories = [
            {
              directory = cfg.dataDir;
              user = primaryUser;
              group = "users";
              mode = "0755";
            }
          ];
        };
  };
}
