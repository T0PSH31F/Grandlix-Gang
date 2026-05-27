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
