let
  flake = builtins.getFlake (toString ./.);
  pkgs = flake.inputs.nixpkgs.legacyPackages.${builtins.currentSystem}.extend (import ./overlays/custom-packages.nix);
in
  pkgs.python3Packages.radios
