# Yazelix — temporarily disabled (replaced by bare stub).
# The option definitions for yazelixIntegration and zellij.yazelix
# are defined in layers/50-cli-tui-programs/default.nix (not here).
# This file formerly contained the HM module import + yazelix home config.
# Removed to resolve duplicate HM module declaration issues.
# To re-enable: restore from git history and fix the conditional
# HM import pattern (import HM module unconditionally, gate config with mkIf).
{
  lib,
  ...
}:
{
  config = lib.mkDefault { };
}
