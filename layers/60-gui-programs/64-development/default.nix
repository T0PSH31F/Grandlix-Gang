{ lib, mkDendriticModule, ... }:
{
  imports = [
    (mkDendriticModule "dev-tools" ./dev-tools.nix)
    (mkDendriticModule "vscode" ./vscode.nix)
  ];
}
