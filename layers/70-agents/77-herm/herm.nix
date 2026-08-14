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
      # Upstream herm is a Bun project. We use the nixpkgs pattern from
      # models-dev, mystmd, swagger-typescript-api: a separate node_modules
      # fixed-output derivation using `bun install --frozen-lockfile`, then
      # copy node_modules into the build env and run `bun run build`.
      hermPkg = pkgs.stdenv.mkDerivation (finalAttrs: {
        pname = "herm-tui";
        version = "1.0.0-dev.1";

        src = pkgs.fetchFromGitHub {
          owner = "liftaris";
          repo = "herm";
          rev = "main";
          hash = "sha256-c4hMCnbK4XdoHsP2dEq8DjtisuazZlakNYwKh2DunKw=";
        };

        nativeBuildInputs = [ pkgs.bun ];

        configurePhase = ''
          runHook preConfigure
          cp -R ${finalAttrs.passthru.node_modules}/. .
          runHook postConfigure
        '';

        buildPhase = ''
          runHook preBuild
          bun run build
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p $out/lib/herm $out/bin
          cp -r dist node_modules package.json $out/lib/herm/
          cat > $out/bin/herm <<'EOF'
          #!${pkgs.runtimeShell}
          exec ${lib.getExe pkgs.bun} $out/lib/herm/dist/index.js "$@"
          EOF
          chmod +x $out/bin/herm
          substituteInPlace $out/bin/herm \
            --replace-fail '$out' "$out"
          runHook postInstall
        '';

        passthru = {
          node_modules = pkgs.stdenv.mkDerivation {
            pname = "${finalAttrs.pname}-node_modules";
            inherit (finalAttrs) version src;

            nativeBuildInputs = [ pkgs.bun ];

            dontConfigure = true;

            buildPhase = ''
              runHook preBuild
              bun install \
                --cpu="*" \
                --frozen-lockfile \
                --ignore-scripts \
                --no-progress \
                --os="*"
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out
              cp -r node_modules $out/
              runHook postInstall
            '';

            dontFixup = true;
            outputHash = "sha256-eDFmLLUQ1Ojdrr+NYyVt6h4a3KOHzlSi7cjM/xeSDRU=";
            outputHashAlgo = "sha256";
            outputHashMode = "recursive";
          };
        };

        meta = with lib; {
          description = "Hermes TUI built with OpenTUI — operator-focused dashboard for Hermes Agent";
          homepage = "https://github.com/liftaris/herm";
          license = licenses.mit;
          mainProgram = "herm";
        };
      });
    in {
      home.packages = [ hermPkg ];
    });
  };
}
