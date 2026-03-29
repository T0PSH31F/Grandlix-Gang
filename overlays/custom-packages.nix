# overlays/custom-packages.nix
# Custom packages you might want available on all systems.

final: prev: {
  # Yazelix Zellij Orchestrator
  yazelix-orchestrator = final.stdenv.mkDerivation {
    pname = "yazelix-orchestrator";
    version = "latest";
    src = final.fetchurl {
      url = "https://raw.githubusercontent.com/luccahuguet/yazelix/main/configs/zellij/plugins/yazelix_pane_orchestrator.wasm";
      sha256 = "sha256-cOkn2Dqm2zHFM3B0sqHHRTpTL/MQmtBbTNoMzIh+xcQ=";
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/yazelix_pane_orchestrator.wasm
    '';
  };

  # Yazelix Zellij Popup Runner
  yazelix-popup-runner = final.stdenv.mkDerivation {
    pname = "yazelix-popup-runner";
    version = "latest";
    src = final.fetchurl {
      url = "https://raw.githubusercontent.com/luccahuguet/yazelix/main/configs/zellij/plugins/yazelix_popup_runner.wasm";
      sha256 = "sha256-jNKKmboyApT00cpvjEc+FGuJ98eAHKseModR8rGEX1M=";
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/yazelix_popup_runner.wasm
    '';
  };

  # Zellij status bar plugin
  zjstatus = final.stdenv.mkDerivation {
    pname = "zjstatus";
    version = "latest";
    src = final.fetchurl {
      url = "https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm";
      sha256 = "sha256-TeQm0gscv4YScuknrutbSdksF/Diu50XP4W/fwFU3VM=";
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/zjstatus.wasm
    '';
  };

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
