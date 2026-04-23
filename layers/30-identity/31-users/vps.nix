# flake-parts/users/vps.nix
{
  ...
}:
{
  home-manager.users."t0psh31f" = {
    imports = [
      ../features/home/cli-tui.nix
    ];

    home.username = "t0psh31f";
    home.homeDirectory = "/home/t0psh31f";

    # Standard sops-nix for home-manager setup
    sops.age.keyFile = "/home/t0psh31f/.config/sops/age/keys.txt";
  };
}
