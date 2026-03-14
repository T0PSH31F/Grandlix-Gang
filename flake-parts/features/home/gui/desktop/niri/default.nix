{
  pkgs,
  ...
}:
{
  imports = [
    ./settings.nix
    ./keybinds.nix
    ./outputs.nix
    ./uwsm.nix
  ];

  home.packages = with pkgs; [
    xwayland-satellite
    nautilus
    alacritty
    fuzzel
  ];
}
