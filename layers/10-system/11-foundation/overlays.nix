# layers/nixos/overlays.nix
# Purpose:
# - Apply all overlays via nixpkgs.overlays for NixOS module evaluation.
# - This is the SINGLE source of truth for overlays.
# - flake.nix pkgsForSystem and perSystem must NOT apply overlays
#   to avoid double-application which changes derivation hashes.

{
  config,
  lib,
  inputs,
  ...
}:

let
  hasTag = tag: builtins.elem tag (config.machine.tags or [ ]);

  themeOverlay = _final: _prev: { };

  # Load overlays from the modular structure
  customOverlay = import ../../80-lib/82-overlays/custom-packages.nix;
  desktopOverlay = import ../../80-lib/82-overlays/desktop-packages.nix;

  # Camoufox anti-detection browser
  camoufoxOverlay = inputs.camoufox-nix.overlays.default;

  # AI package overlay — single import to avoid triple-evaluation.
  aiPkgOverlay = final: _prev: {
    _aiPkgs = import inputs.nixpkgs-ai {
      inherit (final) system;
      config.allowUnfree = true;
    };
    opencode = final._aiPkgs.opencode;
    opencode-desktop = final._aiPkgs.opencode-desktop;
    ollama = final._aiPkgs.ollama;
  };
in
{
  nixpkgs.overlays = [
    camoufoxOverlay
    customOverlay
    aiPkgOverlay
  ]
  ++ lib.optionals (hasTag "desktop") [
    themeOverlay
    desktopOverlay
  ];
}
