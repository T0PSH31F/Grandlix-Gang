let
  flake = builtins.getFlake (toString ./.);
  pkgs = flake.inputs.nixpkgs.legacyPackages.x86_64-linux;
in
  pkgs.python3Packages.radios.overridePythonAttrs (old: {
    pythonRelaxDeps = [ "pycountry" ];
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.python3Packages.pythonRelaxDepsHook ];
  })
