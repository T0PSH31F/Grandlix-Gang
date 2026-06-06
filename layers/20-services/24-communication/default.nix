# flake-parts/services/communication/default.nix
# Communication and collaboration services
{
  imports = [
    ./karakeep.nix
    ./mautrix.nix
    ./your-spotify.nix
    ./signal-cli-daemon.nix
  ];
}
