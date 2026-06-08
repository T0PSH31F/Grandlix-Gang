let
  lib = import <nixpkgs/lib>;
  mkDendriticModule = (import ./layers/80-lib/81-helpers/mkDendriticModule.nix { inherit lib; }).mkDendriticModule;
  
  mockModule = { config, lib, pkgs, ... }: {
    options.foo = lib.mkEnableOption "foo";
    nixos = { environment.systemPackages = [ ]; };
    home = { home.packages = [ ]; };
  };
  
  result = mkDendriticModule "test" mockModule { config = {}; lib = lib; pkgs = {}; };
in
  builtins.attrNames result
