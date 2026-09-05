{
  config,
  lib,
  ...
}:
with lib;
{
  options.services.ai-services.open-webui = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Open WebUI for LLM interfaces";
    };

    port = mkOption {
      type = types.int;
      default = 8088;
      description = "Open WebUI port";
    };
  };

  config =
    let
      cfg = config.services.ai-services.open-webui;
    in
    mkIf cfg.enable {
      services.open-webui = {
        enable = true;
        inherit (cfg) port;
        openFirewall = true;
        environment = {
          OLLAMA_API_BASE_URL = "http://localhost:11434";
          WEBUI_AUTH = "false";
          OPENAI_API_BASE_URLS = "http://127.0.0.1:8642";
        };
      };
    };
}
