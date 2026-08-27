{ mkDendriticModule, ... }:
{
  imports = [
    (mkDendriticModule "databases" ./databases.nix)
    (mkDendriticModule "filebrowser" ./filebrowser.nix)
    (mkDendriticModule "harmonia" ./harmonia.nix)
    (mkDendriticModule "honcho" ./honcho.nix)
    (mkDendriticModule "langfuse" ./langfuse.nix)
    (mkDendriticModule "restic-backups" ./restic-backups.nix)
    (mkDendriticModule "vaultwarden" ./vaultwarden.nix)
  ];
}
