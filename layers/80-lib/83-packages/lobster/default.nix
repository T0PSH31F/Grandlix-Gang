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
    sha256 = "sha256-qMdRBiiBDD8OaSEZ1cnfjA3fKbIrMaGTgrlZGOU8sGg=";
  };

  buildInputs = [ ];

  installPhase = ''
    mkdir -p $out/bin
    if [ -f ./lobster ]; then
      cp ./lobster $out/bin/lobster
    else
      count=$(find . -maxdepth 1 -type f -executable | wc -l)
      if [ "$count" -eq 1 ]; then
        exec_file=$(find . -maxdepth 1 -type f -executable)
        cp "$exec_file" $out/bin/lobster
      else
        echo "Error: Expected exactly 1 executable for $out/bin/lobster via find-based scan, but found $count."
        echo "Maintainers must fix the source layout or specify the exact binary name."
        exit 1
      fi
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
