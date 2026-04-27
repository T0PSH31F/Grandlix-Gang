{ lib, ... }: {
  options.programs.cli-environment = {
    enable = lib.mkEnableOption "CLI Environment Bridge";
    theming.enable = lib.mkEnableOption "Dynamic Theming Bridge";
    headless = lib.mkEnableOption "Headless Bridge";
  };
}
