{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.aionui;
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
  };

  config = mkIf cfg.enable {
    systemd.services.aionui = {
      description = "AionUi — AI agent Cowork web UI";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${lib.getExe aionuiPkg}";
        Restart = "always";
        RestartSec = 5;
        Environment = [
          "PORT=${toString cfg.port}"
          "NODE_ENV=production"
          "ALLOW_REMOTE=true"
          "DATA_DIR=${cfg.dataDir}"
        ];
        StateDirectory = "aionui";
        WorkingDirectory = "${aionuiPkg}";
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
