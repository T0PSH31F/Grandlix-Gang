# development — coding tools, Python, VSCode, dev agents
# Tags-as-data: all config gated by tag membership.
{ config, lib, ... }:
{
  config = lib.mkIf (builtins.elem "development" config.machine.tags) {
    layers = {
      layer-50.cli = {
        pythonTools.enable = lib.mkDefault true;
        zellij.yazelix.bars.enable = lib.mkDefault true;
        azure-cli.enable = lib.mkDefault true;
      };
      layer-70.agent = {
        antigravity.enable = lib.mkDefault true;
        opencode = {
          enable = lib.mkDefault true;
          desktop = lib.mkDefault true;
        };
      };
      layer-60.gui = {
        vscode.enable = lib.mkDefault true;
        dev-tools.enable = lib.mkDefault true;
        brave.enable = lib.mkDefault true;
      };
      layer-20.services.config = {
        ci.auto-update.enable = lib.mkDefault true;
        ci.github-runner.enable = lib.mkDefault true;
        hedgedoc = {
          enable = lib.mkDefault true;
          port = lib.mkDefault 3001;
        };
      };
    };
  };
}
