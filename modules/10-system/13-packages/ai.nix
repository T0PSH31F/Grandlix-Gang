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
        python3Packages.kokoro
        espeak-ng
        onnxruntime
        voxtype-onnx
        python3Packages.pip
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
