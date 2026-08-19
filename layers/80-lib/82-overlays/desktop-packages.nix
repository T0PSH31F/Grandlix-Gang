# overlays/desktop-packages.nix
# Desktop-only packages overlay.
# This file should NOT import nixpkgs again; it should only extend the existing pkgs.

final: prev: {
  jerry = prev.callPackage ../83-packages/jerry { };
  lobster = prev.callPackage ../83-packages/lobster { };
  hypr-dynamic-cursors = prev.hyprlandPlugins.hypr-dynamic-cursors.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/cursor.cpp src/main.cpp src/highres.hpp \
        --replace-warn "hyprland/src/pointer/cursor/CursorManager.hpp" "hyprland/src/managers/CursorManager.hpp"
      substituteInPlace src/cursor.cpp src/cursor.hpp \
        --replace-warn "hyprland/src/pointer/PointerManager.hpp" "hyprland/src/managers/PointerManager.hpp"
      substituteInPlace src/cursor.cpp \
        --replace-warn "m_szName" "m_currentStyleInfo.name"
    '';
  });
}
