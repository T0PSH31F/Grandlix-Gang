{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    let
      system = pkgs.stdenv.hostPlatform.system;
    in
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          inputs.clan-core.packages.${system}.clan-cli
          curl
          deadnix
          git
          nil
          nixd
          nix-fast-build
          nix-search-cli
          nix-top
          nixel
          nixfmt
          nixfmt-tree
          nixpkgs-pytools
          statix
          lolcat
          figlet
        ];

        shellHook = ''
          # Colorize the ASCII art with lolcat
          ${pkgs.lolcat}/bin/lolcat -f ${../02-assets/devshell-banner.txt}

          # Print the text in sblood (ooze) font colorized with lolcat
          ${pkgs.figlet}/bin/figlet -c -f sblood "Nix Flake Pirate Crew" | ${pkgs.lolcat}/bin/lolcat -f

          echo ""
          echo "Quick start:"
          echo "  nix develop github:T0PSH31F/grandlix-devenvs#python-ai-agent"
          echo ""
        '';
      };
    };
}
