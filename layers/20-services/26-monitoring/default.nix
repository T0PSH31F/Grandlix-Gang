{ mkDendriticModule, ... }:
{
  imports = [
    (mkDendriticModule "alertmanager-ntfy" ./alertmanager-ntfy.nix)
    (mkDendriticModule "glances" ./glances.nix)
    (mkDendriticModule "homepage-dashboard" ./homepage-dashboard.nix)
    (mkDendriticModule "monitoring" ./monitoring.nix)
    (mkDendriticModule "ntfy-sh" ./ntfy-sh.nix)
  ];
}
