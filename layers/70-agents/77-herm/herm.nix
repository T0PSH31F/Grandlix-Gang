{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-77.herm;
in
{
  options.layers.layer-77.herm = {
    enable = lib.mkEnableOption "Herm TUI — operator dashboard for Hermes Agent";
  };

  home = { ... }: {
    config = lib.mkIf cfg.enable (let
      # Project uses bun (bun.lock) — buildNpmPackage needs package-lock.json.
      # Generate it from bun.lock in a patched source derivation.
      rawSrc = pkgs.fetchFromGitHub {
        owner = "liftaris";
        repo = "herm";
        rev = "main";
        hash = "sha256-c4hMCnbK4XdoHsP2dEq8DjtisuazZlakNYwKh2DunKw=";
      };

      # Patch source with package-lock.json to satisfy buildNpmPackage.
      # Uses fixed-output derivation so npm can reach the registry.
      patchedSrc = pkgs.runCommand "herm-src-with-lockfile" {
        nativeBuildInputs = [ pkgs.nodejs ];
        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash = lib.fakeSha256;
      } ''
        cp -rs ${rawSrc} source
        chmod -R u+w source
        cd source
        npm install --package-lock-only
        if [ ! -f package-lock.json ]; then
          echo "ERROR: Failed to generate package-lock.json"
          exit 1
        fi
        mkdir -p $out
        cp -r . $out/
      '';

      hermPkg = pkgs.buildNpmPackage rec {
        pname = "herm-tui";
        version = "0.1.0";

        src = patchedSrc;

        nativeBuildInputs = [ pkgs.bun ];

        npmDepsHash = lib.fakeHash;

        npmBuildScript = "build";

        meta = with lib; {
          description = "Hermes TUI built with OpenTUI — operator-focused dashboard for Hermes Agent";
          homepage = "https://github.com/liftaris/herm";
          license = licenses.mit;
          mainProgram = "herm";
        };
      };
    in {
      home.packages = [ hermPkg ];
    });
  };
}
