{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  wayland,
  wayland-protocols,
  wayland-scanner,
  libarchive,
  uthash,
  python3,
}:
let
  pythonEnv = python3.withPackages (ps: [ ps.pillow ]);
in
stdenv.mkDerivation rec {
  pname = "wl_shimeji";
  version = "0.1.0-unstable-2026-08-13";

  src = fetchFromGitHub {
    owner = "CluelessCatBurger";
    repo = "wl_shimeji";
    rev = "787b5a072a9d1439af26fb2d247ba0822498023c";
    hash = "sha256-WXvjsLAdcWozy0LS0h1/915v/sqxVp0Z5Pa9XYagFvc=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    wayland-scanner
  ];

  buildInputs = [
    wayland
    wayland-protocols
    libarchive
    uthash
  ];

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    if [ -f wl_shimeji ]; then
      cp wl_shimeji $out/bin/
    fi
    if [ -f shimejictl ]; then
      cp shimejictl $out/bin/
      wrapProgram $out/bin/shimejictl \
        --prefix PATH : ${lib.makeBinPath [ pythonEnv ]}
    fi
    runHook postInstall
  '';

  meta = with lib; {
    description = "Wayland desktop mascot app (wl_shimeji)";
    homepage = "https://github.com/CluelessCatBurger/wl_shimeji";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "wl_shimeji";
  };
}
