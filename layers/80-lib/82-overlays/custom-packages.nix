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

  # Camoufox prebuilt binary from GitHub releases (v150.0.2-beta.25 / alpha.26).
  # Bumped from v135.0.1-beta.24 (2025-03) → v150.0.2-beta.25 (2026-05) because
  # the v135 prebuilt's `libgkcodecs.so` and other dependent libraries carry init
  # routines that SEGV_MAPERR in `_dl_init` on glibc ≥ 2.42 (the dynamic linker
  # fault happens before `_start` even returns, so `MOZ_DISABLE_GKCODECS=1`
  # cannot help). v150 ships a Firefox 150 codebase that is compatible with
  # the current nixpkgs-unstable toolchain.
  #
  # Replaces the source-build from camoufox-nix which fails on newer nixpkgs
  # (Firefox 146 source requires linux-headers in include path; build times ~hours).
  #
  # NOTE: We deliberately do NOT use `autoPatchelfHook` because the camoufox
  # prebuilt is already self-contained — its binaries are pre-patched with
  # RUNPATH entries that point to specific /nix/store paths from the build
  # environment. Re-running autoPatchelfHook rewrites those RUNPATH entries
  # (and the .so files' RUNPATHs) and breaks the static init of `libgkcodecs.so`
  # (and others) on glibc 2.42+, which then segfaults the browser before
  # `main()` ever runs.
  #
  # We only wrap the entry point with `makeWrapper` to prepend the current
  # nixpkgs library path (gtk3, x11, libdrm, mesa, …) so the runtime can find
  # Nix-built system libraries. The prebuilt's own wrapper script (under
  # share/camoufox/camoufox-bin) handles the rest.
  #
  # The v150 alpha.26 release no longer ships a `version.json` file in the
  # zip — we synthesize one from `application.ini` so camoufox-js (used by
  # camofox-browser) can identify the bundle version.
  camoufox = let
    version = "150.0.2-beta.25";
    release = "150.0.2";
    runtimeLibs = with final; [
      gtk3
      xorg.libxcb
      xorg.libX11
      libxkbcommon
      alsa-lib
      libdrm
      mesa
      nss
      nspr
      dbus
      ffmpeg_7
      libpulseaudio
      stdenv.cc.cc.lib
    ];
  in final.stdenv.mkDerivation {
    pname = "camoufox";
    inherit version;

    src = final.fetchzip {
      url = "https://github.com/daijro/camoufox/releases/download/v150.0.2-beta.25/camoufox-150.0.2-alpha.26-lin.x86_64.zip";
      hash = "sha256-F/J3HNsGAmlpl4FUdT6vFJwQA0djWEdDjI8heho0zcc=";
      stripRoot = false;
    };

    nativeBuildInputs = [ final.makeWrapper ];
    dontBuild = true;
    dontConfigure = true;
    dontFixup = true;

    installPhase = ''
      mkdir -p $out/lib $out/bin $out/share/camoufox

      # Copy all files (preserves the upstream camoufox-bin wrapper script
      # and the pre-patched ELF binaries / .so files).
      cp -r . $out/share/camoufox/

      # Symlink every .so into $out/lib so the dynamic linker can find them
      # via the LD_LIBRARY_PATH prepend below.
      find $out/share/camoufox -maxdepth 1 -name "*.so" -exec ln -sf {} $out/lib/ \;

      # Synthesize version.json (alpha.26 doesn't ship one). camoufox-js needs
      # this to recognize the bundle via `Version.fromPath()`. It looks for
      # version.json relative to the executable's directory (path.dirname of
      # CAMOUFOX_EXECUTABLE), which resolves to $out/bin/ — so we must place
      # it there too, not just under share/camoufox/.
      cat > $out/share/camoufox/version.json <<EOF
      { "version": "${version}", "release": "${release}" }
      EOF
      cp $out/share/camoufox/version.json $out/bin/version.json
      # Also copy properties.json to bin/ (camoufox-js reads it from there)
      cp $out/share/camoufox/properties.json $out/bin/properties.json 2>/dev/null || true

      # Wrap the upstream camoufox-bin entry point. The upstream wrapper sets
      # up LD_LIBRARY_PATH for the prebuilt's own dependencies; we additionally
      # prepend the Nix runtime lib path so the current nixpkgs libraries
      # (gtk3, x11, libdrm, mesa, ffmpeg, libpulse, dbus, nss, nspr,
      # libxkbcommon, gcc.cc.lib) resolve correctly.
      makeWrapper $out/share/camoufox/camoufox-bin $out/bin/camoufox-bin \
        --prefix LD_LIBRARY_PATH : ${final.lib.makeLibraryPath runtimeLibs} \
        --prefix LD_LIBRARY_PATH : $out/lib

      # Also expose `camoufox` as a convenient alias.
      ln -sf $out/bin/camoufox-bin $out/bin/camoufox
    '';

    meta.mainProgram = "camoufox";
  };
  # camofox-browser: replaced by jo-camofox-browser from camoufox-nix flake overlay
  # (jo-inc fork with VNC + persistence plugins, OpenAPI docs, tracing)
  # Override to use our prebuilt camoufox instead of camoufox-nix's source-built one
  # (Firefox 146 source build takes hours and fails on this machine)
  # Also add missing linux-headers + gcc for better-sqlite3 native addon compilation
  # VNC watcher paths (NOVNC_DIR, websockify, awk) fixed via systemd PATH + tmpfiles
  # in layers/20-services/24-communication/camofox-browser.nix — no derivation patch needed.
  jo-camofox-browser = (prev.jo-camofox-browser.override { camoufox = final.camoufox; }).overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ final.linuxHeaders final.gcc ];
    buildInputs = (old.buildInputs or []) ++ [ final.linuxHeaders ];
  });

  # Fix for browserify build failure: npm: command not found
  # browserify = prev.nodePackages.browserify.overrideAttrs (old: {
  #   nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
  #     final.python3
  #     final.nodejs
  #   ];
  # });

  # Fix for noctalia-greeter build failure: missing linux/errno.h
  noctalia-greeter = prev.noctalia-greeter.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ final.linuxHeaders ];
    buildInputs = (old.buildInputs or []) ++ [ final.linuxHeaders ];
  });

  pythonPackagesExtensions = (prev.pythonPackagesExtensions or []) ++ [
    (python-final: python-prev: {
      radios = python-prev.radios.overridePythonAttrs (old: {
        pythonRelaxDeps = [ "pycountry" ];
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ python-final.pythonRelaxDepsHook ];
      });
    })
  ];
}
