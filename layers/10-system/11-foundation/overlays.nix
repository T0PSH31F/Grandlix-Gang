# layers/nixos/overlays.nix
# Purpose:
# - Apply all overlays via nixpkgs.overlays for NixOS module evaluation.
# - This is the SINGLE source of truth for overlays.
# - flake.nix pkgsForSystem and perSystem reference the same overlays
#   to keep the flake-parts and clan pkgs in sync.

{
  config,
  lib,
  inputs,
  ...
}:

let
  hasTag = tag: builtins.elem tag (config.machine.tags or [ ]);

  themeOverlay = final: prev: { };

  # Load overlays from the modular structure
  customOverlay = import ../../80-lib/82-overlays/custom-packages.nix;
  desktopOverlay = import ../../80-lib/82-overlays/desktop-packages.nix;

  # Camoufox anti-detection browser (source-built Firefox fork)
  camoufoxOverlay = inputs.camoufox-nix.overlays.default;

  # AI package overlay — swaps opencode/opencode-desktop/ollama to bleeding-edge
  # from the nixpkgs-ai flake input (updated independently from nixos-unstable).
  # Single import to avoid triple-evaluation of nixpkgs-ai.
  aiPkgOverlay = final: prev: {
    _aiPkgs = import inputs.nixpkgs-ai {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
    opencode = final._aiPkgs.opencode;
    opencode-desktop = final._aiPkgs.opencode-desktop;
    ollama = final._aiPkgs.ollama;
  };
in
{
  # Core overlays always applied
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
