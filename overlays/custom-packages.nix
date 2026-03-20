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

  # Fix for python dependency check failures in instructor and hyperpyyaml
  # pythonPackagesOverlay = pyfinal: pyprev: {
  #   instructor = pyprev.instructor.overrideAttrs (old: {
  #     dontCheckRuntimeDeps = true;
  #   });
  #   hyperpyyaml = pyprev.hyperpyyaml.overrideAttrs (old: {
  #     dontCheckRuntimeDeps = true;
  #   });
  # };

  # python3 = prev.python3.override {
  #   packageOverrides = final.pythonPackagesOverlay;
  # };
  # python313 = prev.python313.override {
  #   packageOverrides = final.pythonPackagesOverlay;
  # };

  # Fix for Electron 39.x build failure (broken cherry-pick patch)
  electron-unwrapped_39 = (prev.electron_39 or prev.electron).unwrapped.overrideAttrs (old: {
    patches = builtins.filter (p:
      let
        name =
          if builtins.isPath p then
            builtins.baseNameOf (builtins.toString p)
          else if p ? name then
            p.name
          else
            "";
      in
      !(builtins.match ".*angle-patchdir.*" name != null)
      && !(builtins.match ".*cherry-pick-a08731cf6d70.*" name != null)
    ) (old.patches or [ ]);

    postUnpack = (old.postUnpack or "") + ''
      # Aggressively remove broken cherry-pick patch from any JSON config
      find . -name "*.json" -exec sed -i '/cherry-pick-a08731cf6d70/d' {} + || true
    '';

    prePatch = (old.prePatch or "") + ''
      # Double-check removal before patchPhase
      find . -name "*.json" -exec sed -i '/cherry-pick-a08731cf6d70/d' {} + || true
    '';
  });

  electron_39 = prev.electron_39.overrideAttrs (old: {
    buildCommand = builtins.replaceStrings
      [ "${prev.electron_39.unwrapped}" ]
      [ "${final.electron-unwrapped_39}" ]
      old.buildCommand;
    passthru = (old.passthru or { }) // {
      unwrapped = final.electron-unwrapped_39;
    };
  });

  # Workaround for broken Electron 39.x in nixpkgs unstable.
  # We apply this prefix match to ensure any 39.x release is patched to remove
  # the broken cherry-pick patch that prevents successful builds.
  electron =
    if prev.lib.hasPrefix "39." (prev.electron.version or "") then
      final.electron_39
    else
      prev.electron;
}
