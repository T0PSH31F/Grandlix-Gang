# flake-parts/features/home/default.nix
# Home Manager feature toggles - user-level tools and applications
{
  imports = [
    ./agent
    ./cli
    ./core.nix
    ./gui
  ];
}
