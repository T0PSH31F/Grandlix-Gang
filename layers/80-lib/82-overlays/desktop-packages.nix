# overlays/desktop-packages.nix
# Desktop-only packages overlay.
# This file should NOT import nixpkgs again; it should only extend the existing pkgs.

final: prev: {
  jerry = prev.callPackage ../83-packages/jerry { };
  lobster = prev.callPackage ../83-packages/lobster { };

}
