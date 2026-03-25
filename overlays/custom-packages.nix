# overlays/custom-packages.nix
# Custom packages you might want available on all systems.

final: prev: {
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

}
