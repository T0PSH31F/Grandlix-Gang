{ inputs, ... }:
{
  perSystem =
    {
      config,
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
          ${config.checks.pre-commit-check.shellHook or ""}

          # Ensure repository git identity is properly configured
          if [ -d .git ]; then
            git config --local user.name "t0psh31f"
            git config --local user.email "wrighterik77@gmail.com"
          fi

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
