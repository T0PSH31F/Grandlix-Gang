{ lib, ... }:
let
  inherit (import ../../../layers/80-lib/81-helpers/mkDendriticModule.nix { inherit lib; })
    mkDendriticModule
    ;
in
{
  imports = [
    (mkDendriticModule "dev-tools" ./dev-tools.nix)
    (mkDendriticModule "vscode" ./vscode.nix)
  ];
}
