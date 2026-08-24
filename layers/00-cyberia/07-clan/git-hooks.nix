# Git Pre-commit & Pre-push Hooks
# Wire nixfmt, deadnix, statix for pre-commit and fast nix eval of both machine toplevels for pre-push.
# Prevents pushed syntax failures (opencode brace class of errors).
{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    {
      checks.pre-commit-check = inputs.git-hooks-nix.lib.${system}.run {
        src = ../../../.;
        hooks = {
          nixfmt-rfc-style = {
            enable = true;
            package = pkgs.nixfmt;
          };
          deadnix = {
            enable = true;
            package = pkgs.deadnix;
          };
          statix = {
            enable = true;
            package = pkgs.statix;
          };
          nix-eval-toplevels = {
            enable = true;
            name = "Fast nix eval of machine toplevels";
            entry = "nix eval --raw .#nixosConfigurations.luffy.config.system.build.toplevel.drvPath > /dev/null && nix eval --raw .#nixosConfigurations.z0r0.config.system.build.toplevel.drvPath > /dev/null";
            stages = [ "pre-push" ];
            pass_filenames = false;
          };
        };
      };
    };
}
