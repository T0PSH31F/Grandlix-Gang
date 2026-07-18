{ ... }:
{
  imports = [
    ./adguard.nix
    ./avahi.nix
    ./caddy.nix
    ./gateway.nix
    ./headscale.nix
    ./ssh-agent.nix
    ./tailscale.nix
    ./zerotier.nix
  ];
}
