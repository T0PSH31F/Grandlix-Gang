# flake-parts/features/home/default.nix
# Home Manager feature toggles - user-level tools and applications
{
  imports = [
    ../../70-agents/default.nix
    ../default.nix
    ./core.nix
    ../../60-gui-programs/default.nix
  ];
}
