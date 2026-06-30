# overlays/custom-packages.nix
# Custom packages you might want available on all systems.

final: prev: {
  # Yazelix Zellij Orchestrator
  yazelix-orchestrator = final.stdenv.mkDerivation {
    pname = "yazelix-orchestrator";
    version = "v14";
    src = final.fetchurl {
      url = "https://raw.githubusercontent.com/luccahuguet/yazelix/v14/configs/zellij/plugins/yazelix_pane_orchestrator.wasm";
      sha256 = "sha256-H4uAqyJbx7HHy0vRXZOqDeG1UkkTmfwqZ4qCuAOviOc=";
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/lib
      cp $src $out/lib/yazelix_pane_orchestrator.wasm
    '';
  };

  # Yazelix Zellij Popup Runner
  yazelix-popup-runner = final.stdenv.mkDerivation {
    pname = "yazelix-popup-runner";
    version = "v14";
    src = final.fetchurl {
      url = "https://raw.githubusercontent.com/luccahuguet/yazelix/v14/configs/zellij/plugins/yazelix_popup_runner.wasm";
      sha256 = "sha256-7m8EXc8DHDZEtcT1PYvulHYIeDB8laprpqCSY7oJl4Y=";
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/lib
      cp $src $out/lib/yazelix_popup_runner.wasm
    '';
  };

  # Zellij status bar plugin
  zjstatus = final.stdenv.mkDerivation {
    pname = "zjstatus";
    version = "0.20.2";
    src = final.fetchurl {
      url = "https://github.com/dj95/zjstatus/releases/download/v0.20.2/zjstatus.wasm";
      sha256 = "sha256-OSg7Q1AWKW32Y9sHWJbWOXWF1YI5mt0N4Vsa2fcvuNg=";
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/lib
      cp $src $out/lib/zjstatus.wasm
    '';
  };

  # Disable glances test suite as they try to bind to localhost and fail in sandbox
  glances = prev.glances.overridePythonAttrs (old: {
    doCheck = false;
  });

  # Disable openldap tests only for i686-linux (32-bit) builds to prevent flaky test failures on cache misses,
  # while keeping the x86_64-linux build identical to nixpkgs to preserve binary cache hits.
  openldap = prev.openldap.overrideAttrs (old: {
    doCheck = !(prev.stdenv.hostPlatform.system == "i686-linux");
  });

  # Disable pipx tests as they are currently failing on Python 3.13
  pipx = prev.pipx.overrideAttrs (old: {
    doCheck = false;
    doInstallCheck = false;
    pytestCheckPhase = "true";
  });

  # Fix for noto-fonts-subset build failure (cp fails when glob matches no files)
  noto-fonts-subset = final.runCommand "noto-fonts-subset" { } ''
    mkdir -p "$out/share/fonts/noto/"
    for f in "${final.noto-fonts}/share/fonts/noto/"NotoSans*.[ot]tf; do
      if [ -e "$f" ]; then
        cp -v "$f" "$out/share/fonts/noto/"
      fi
    done
    # Ensure at least an empty output so downstream doesn't fail
    touch "$out/share/fonts/noto/.keep"
  '';

  # Camoufox browser binary is now provided by camoufox-nix flake overlay
  # (source-built from Firefox, avoids prebuilt binary SIGSEGV on NixOS)
  # camofox-browser (Node.js CDP wrapper) is still packaged here from @askjo v1.11.2
  camofox-browser = let
    camofoxLock = ./camofox-browser-lock.json;
    nodejs = final.nodejs_22;
  in final.buildNpmPackage {
    inherit nodejs;
    pname = "camofox-browser";
    version = "1.11.2";
    src = final.fetchurl {
      url = "https://registry.npmjs.org/@askjo/camofox-browser/-/camofox-browser-1.11.2.tgz";
      sha256 = "sha256-+JJDDt+kKs0BhtCCspMNy8rTzMAQZLVa+L9HuDbpk4c=";
    };
    sourceRoot = "package";
    nativeBuildInputs = [ nodejs final.python3 final.gcc final.makeWrapper final.linuxHeaders ];
    buildInputs = [ final.linuxHeaders ];

    npmDeps = final.fetchNpmDeps {
      src = final.runCommand "camofox-browser-deps-src" { } ''
        mkdir -p $out
        cp ${camofoxLock} $out/package-lock.json
      '';
      hash = "sha256-bfKlCo9J6E+CToHmOBOE2D1MOu4SmHDcg3JYj7DB+Mc=";
    };

    postPatch = ''
      cp ${camofoxLock} package-lock.json
    '';

    dontNpmBuild = true;
    NODE_ENV = "production";

    installPhase = ''
      pushd node_modules/better-sqlite3
      rm -rf build/Release/better_sqlite3.node build/Release/obj build/Release/obj.target build/Release/.deps
      ${nodejs}/bin/node ${nodejs}/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js rebuild --release
      popd

      mkdir -p $out/lib/node_modules/@askjo/camofox-browser
      cp -r . $out/lib/node_modules/@askjo/camofox-browser/
      mkdir -p $out/bin
      cat > $out/bin/camofox-server << WRAPPER
#!${final.runtimeShell}
export NODE_PATH=$out/lib/node_modules/@askjo/camofox-browser/node_modules
export CAMOFOX_DATA_DIR="''${CAMOFOX_DATA_DIR:-\$HOME/.camofox}"
exec ${nodejs}/bin/node $out/lib/node_modules/@askjo/camofox-browser/server.js "\$@"
WRAPPER
      chmod +x $out/bin/camofox-server
    '';
    meta.mainProgram = "camofox-server";
  };

  # Fix for browserify build failure: npm: command not found
  # browserify = prev.nodePackages.browserify.overrideAttrs (old: {
  #   nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
  #     final.python3
  #     final.nodejs
  #   ];
  # });

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (python-final: python-prev: {
      radios = python-prev.radios.overridePythonAttrs (old: {
        pythonRelaxDeps = [ "pycountry" ];
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ python-final.pythonRelaxDepsHook ];
      });
    })
  ];
}
