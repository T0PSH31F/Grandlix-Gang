# flake-parts/features/nixos/packages/ai.nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  hasTag = tag: builtins.elem tag (config.machine.tags or [ ]);
in
{

  config = lib.mkMerge [
    (lib.mkIf (hasTag "ai-server") {
      environment.systemPackages = with pkgs; [
        ollama
        # python3Packages.kokoro  # DROPPED: pulls onnxruntime transitively, not used by GLaDOS (uses piper-tts)
        espeak-ng
        # onnxruntime  # DROPPED: only used by voxtype-onnx, not GLaDOS (uses piper-tts)
        # voxtype-onnx  # DROPPED: not used anywhere
        pipx
      ];
    })
    {
      services.hyprwhspr-rs = {
        enable = true;
      };
    }
  ];
}
