{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.nix-tools = {
    enable = mkEnableOption "Nix development and helper tools";
  };

  config = mkIf config.nix-tools.enable {
    # NH - NixOS Helper
    # Provides cleaner commands: nh os switch, nh os boot, nh os test, etc.
    programs.nh = {
      enable = true;
      clean.enable = false;
      clean.extraArgs = "--keep-since 7d --keep 5";
      flake = "/home/t0psh31f/Clan/NFP";
    };

    # Install nom (Nix Output Monitor)
    # Usage: nom build, nom shell, etc. - prettier build output
    environment.systemPackages = with pkgs; [
      #nil
      arion
      comma
      compose2nix
      deadnix
      dix
      envoluntary
      manix
      mcp-nixos
      nix-diff
      nix-serve-ng
      nix-sweep
      nix-unit 
      nix-btm
      nix-olde
      nix-health
      nix-fast-build
      nix-init
      nix-inspect
      nix-output-monitor # nom command
      nix-search-tv
      nix-top
      nix-tree # Interactive nix dependency tree viewer
      nix-zsh-completions
      nixel
      nixd
      nixfmt-tree
      nixos-option
      nvd # Nix/NixOS package version diff tool
      omnix
      optinix
      optnix
      statix
      vulnix
    ];
    # Enable nix-index database generation
    programs = {
      command-not-found.enable = false;
      nix-index = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };
    };

    # Helpful shell aliases for home-manager users
    home-manager.users.t0psh31f = {
      programs.nix-your-shell = {
        enable = true;
        enableZshIntegration = true;
        nix-output-monitor.enable = true;
      };
      home.shellAliases = {
        cunt = "clan machines update nami";
        cumz = "clan machines update z0r0";
        cum = "clan machines update";
        # NH shortcuts
        nos = "nh os switch";
        nob = "nh os boot";
        not = "nh os test";
        noc = "nh clean all";

        # Nom shortcuts
        nb = "nom build";
        ndev = "nom develop";

        # Nix helpers
        ndiff = "nvd diff /run/current-system result";
        ntree = "nix-tree";
      };
    };
  };
}
