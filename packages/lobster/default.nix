{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "lobster";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "justchokingaround";
    repo = "lobster";
    rev = "main";
    sha256 = "sha256-EL2AXO/HhbaXPwc4MgsKIvut5CPW1TJYwn87E3OIIes=";
  };

  buildInputs = [ ];

  installPhase = ''
    mkdir -p $out/bin
    if [ -f lobster ]; then
      cp lobster $out/bin/
    else
      find . -maxdepth 1 -type f -executable -exec cp {} $out/bin/lobster \;
    fi
    chmod +x $out/bin/lobster
  '';

  meta = with lib; {
    description = "Lobster desktop helper";
    homepage = "https://github.com/justchokingaround/lobster";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
