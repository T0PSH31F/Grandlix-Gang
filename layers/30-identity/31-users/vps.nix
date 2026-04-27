{
  ...
}:
{
  home-manager.users."t0psh31f" = {
    imports = [
      ../../50-cli-tui-programs/50-entry/cli-tui.nix
    ];

    home.username = "t0psh31f";
    home.homeDirectory = "/home/t0psh31f";

    sops.age.keyFile = "/home/t0psh31f/.config/sops/age/keys.txt";
  };
}
