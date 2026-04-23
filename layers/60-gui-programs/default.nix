# flake-parts/features/home/gui/default.nix
# GUI Home Manager modules
{
  imports = [
    ../40-desktop/default.nix
    ./63-documents/default.nix
    ./64-development/dev-tools.nix
    ./65-gaming/gaming-apps.nix
    ./66-security/pentest-tools.nix
    ./62-media/spicetify.nix
    ./64-development/vscode.nix
  ];
}
