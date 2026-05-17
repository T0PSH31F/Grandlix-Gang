{ config, lib, pkgs, ... }:
let cfg = config.layers.layer-60.gui.activities.office;
in {
  options.layers.layer-60.gui.activities.office.enable = lib.mkEnableOption "Office Suite";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ libreoffice hunspell hunspellDicts.en_US-large ];
  };
}
