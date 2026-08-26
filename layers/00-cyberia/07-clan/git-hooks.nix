# Git Pre-commit & Pre-push Hooks
# Delegates all Nix formatting/linting to the single treefmt-nix wrapper defined in
# flake.nix (nixfmt + deadnix + statix + nixf-diagnose + shfmt) so there is exactly
# one source of truth for "how do we format this repo" — see flake.nix's
# perSystem.treefmt. Fast nix eval of both machine toplevels guards pre-push.
{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      system,
      config,
      ...
    }:
    {
      checks.pre-commit-check = inputs.git-hooks-nix.lib.${system}.run {
        src = ../../../.;
        hooks = {
          treefmt = {
            enable = true;
            package = config.treefmt.build.wrapper;
          };
          nix-eval-toplevels = {
            enable = true;
            name = "Fast nix eval of machine toplevels";
            entry = toString (
              pkgs.writeShellScript "nix-eval-toplevels" ''
                set -euo pipefail
                nix eval --raw .#nixosConfigurations.luffy.config.system.build.toplevel.drvPath > /dev/null
                nix eval --raw .#nixosConfigurations.z0r0.config.system.build.toplevel.drvPath > /dev/null
              ''
            );
            stages = [ "pre-push" ];
            pass_filenames = false;
          };
        };
      };
    };
}
