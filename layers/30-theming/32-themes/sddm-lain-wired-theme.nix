{ lib, stdenv, src, qt5 }:

    stdenv.mkDerivation rec {
      pname = "sddm-lain-wired-theme";
      version = "0.9.1";

      inherit src;

      # Add Qt dependencies that SDDM themes typically need
      nativeBuildInputs = [ qt5.wrapQtAppsHook ];
      buildInputs = with qt5; [ qtbase qtquickcontrols2 qtgraphicaleffects qtsvg ];

      dontBuild = true;
      dontWrapQtApps = true;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/sddm/themes/${pname}
        cp -r * $out/share/sddm/themes/${pname}/

        # Ensure proper permissions
        chmod -R 755 $out/share/sddm/themes/${pname}

        # Ensure metadata.desktop is readable
        chmod 644 $out/share/sddm/themes/${pname}/metadata.desktop

        runHook postInstall
      '';

      meta = with lib; {
        description = "Lain Wired SDDM theme inspired by fauux.neocities.org";
        homepage = "https://github.com/lll2yu/sddm-lain-wired-theme";
        license = licenses.cc-by-sa-40;
        platforms = platforms.linux;
        maintainers = [ t0psh31f ];
      };
    }
