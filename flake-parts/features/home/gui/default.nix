# flake-parts/features/home/gui/default.nix
# GUI Home Manager modules
{
  imports = [
    ./desktop
    ./documents/default.nix
    ./dev-tools.nix
    ./gaming-apps.nix
    ./pentest-tools.nix
    ./spicetify.nix
    ./vscode.nix
    ./antigravity.nix
  ];
}
