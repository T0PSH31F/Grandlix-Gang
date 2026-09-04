# flake-parts/features/nixos/packages/dev.nix
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
  config = lib.mkIf (hasTag "development") {
    environment.systemPackages = with pkgs; [
      # Compilers & build tools
      #       antigravity
      binutils
      cmake
      gcc
      gnumake
      libgcc
      pkg-config

      # Debugging
      gdb
      valgrind

      # Dev environments
      devenv
      direnv

      # Languages
      yarn
      nodejs
      pnpm
      poetry
      typescript
      uv

      # VCS / dev tooling
      gh
      git-lfs
      gitFull
    ];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
