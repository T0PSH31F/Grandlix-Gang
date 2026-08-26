# Module evaluation check — verifies homepage-dashboard module evaluates correctly
{ pkgs, ... }:
pkgs.testers.nixosTest {
  name = "homepage-dashboard-module";
  nodes.machine = { config, lib, ... }: {
    imports = [ ../../layers/20-services/26-monitoring/homepage-dashboard.nix ];
    layers.layer-20.services.config.homepage-dashboard = {
      enable = true;
      lovable.enable = true;
    };
    layers.layer-10.system.config.impermanence.enable = false;
    networking.hostName = "z0r0";
    nixpkgs.hostPlatform = pkgs.stdenv.hostPlatform.system;
    system.stateVersion = "25.05";
  };
  testScript = ''
    machine.wait_for_unit("homepage-dashboard.service")
    machine.wait_for_open_port(8082)
    machine.succeed("curl -s http://localhost:8082 | grep -q 'Nix Flake Pirates'")
  '';
}
