{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "jerry";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "justchokingaround";
    repo = "jerry";
    rev = "1x2c6yj3z16az7zy2hsd7hdm3gh1vajxmxw9alfzws9ni6yqvg27";
    sha256 = "sha256-R7yNvYk2af4dVYn32qXaAb5RGzxNQ+H/+cqEP6Q3TPQ=";
  };

  # Adjust buildInputs and installPhase to whatever jerry actually needs
  buildInputs = [ ];

  installPhase = ''
    mkdir -p $out/bin
    if [ -f jerry ]; then
      cp jerry $out/bin/
    else
      find . -maxdepth 1 -type f -executable -exec cp {} $out/bin/jerry \;
    fi
    chmod +x $out/bin/jerry
  '';

  meta = with lib; {
    description = "Jerry tool (desktop-only)";
    homepage = "https://github.com/justchokingaround/jerry";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
