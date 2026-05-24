# llama.cpp HTTP Server NixOS Service
# layers/20-services/22-ai/llama-cpp.nix
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.llama-cpp-server;
  selectedLlamaPkg =
    if cfg.acceleration == "cuda" then
      pkgs.llama-cpp.override { cudaSupport = true; }
    else if cfg.acceleration == "rocm" then
      pkgs.llama-cpp.override { rocmSupport = true; }
    else
      pkgs.llama-cpp;
in
{
  options.services.llama-cpp-server = {
    enable = mkEnableOption "llama.cpp HTTP server";

    port = mkOption {
      type = types.port;
      default = 8083;
      description = "Port to listen on";
    };

    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Host address to bind to";
    };

    model = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to the GGUF model file";
      example = "/var/lib/llama-cpp/models/llama-3-8b.gguf";
    };

    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Extra command-line flags to pass to llama-server";
      example = [
        "-ngl"
        "99"
        "--threads"
        "4"
      ];
    };

    acceleration = mkOption {
      type = types.nullOr (
        types.enum [
          "cuda"
          "rocm"
          false
        ]
      );
      default = null;
      description = "GPU acceleration type (cuda, rocm, or false to disable)";
    };
  };

  config = mkIf cfg.enable {
    # 1. System packages for raw binary access in CLI
    environment.systemPackages = [ selectedLlamaPkg ];

    # 2. Systemd Service
    systemd.services.llama-cpp-server = {
      description = "llama.cpp HTTP Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart =
          let
            args = [
              "--host"
              cfg.host
              "--port"
              (toString cfg.port)
            ]
            ++ (lib.optional (cfg.model != null) "-m")
            ++ (lib.optional (cfg.model != null) (toString cfg.model))
            ++ cfg.extraFlags;
          in
          "${selectedLlamaPkg}/bin/llama-server ${escapeShellArgs args}";

        User = "llama-cpp";
        Group = "llama-cpp";
        WorkingDirectory = "/var/lib/llama-cpp";
        StateDirectory = "llama-cpp";
        Restart = "on-failure";
        PrivateTmp = true;
        ProtectSystem = "full";
        ProtectHome = true;
      };
    };

    # 3. Create static system user
    users.users.llama-cpp = {
      group = "llama-cpp";
      isSystemUser = true;
      description = "llama.cpp Server User";
      home = "/var/lib/llama-cpp";
      createHome = true;
    };
    users.groups.llama-cpp = { };

    # 4. Open firewall
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    # 5. Impermanence persistence support
    environment.persistence."/persist" =
      mkIf (config.layers.layer-10.system.config.impermanence.enable or false)
        {
          directories = [
            {
              directory = "/var/lib/llama-cpp";
              user = "llama-cpp";
              group = "llama-cpp";
              mode = "0750";
            }
          ];
        };
  };
}
