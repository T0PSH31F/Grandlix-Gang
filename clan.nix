let
  machinesInventory = {
    z0r0 = {
      tags = [
        "workstation"
        "desktop"
        "development"
        "gaming"
        "media-server"
        "laptop"
        "media"
        "ai-server"
      ];
      deploy.targetHost = "root@100.95.168.90";
    };

    luffy = {
      tags = [
        "workstation"
        "desktop"
        "gaming"
        "server"
        "homelab"
        "cache-server"
        "ai-server"
        "development"
        "media"
      ];
      deploy.targetHost = "root@100.80.146.120";
    };

  };
  mkMachineFromTags = tags: map (tag: ./layers/90-profiles/tags/${tag}.nix) tags;
in
{
  imports = [
    # ./clan-service-layers/default.nix # Removed due to class mismatch (clan.service vs clan)
  ];

  meta.name = "NFP";

  inventory = {
    machines = machinesInventory;
    instances = {
      wireguard = {
        module = {
          name = "wireguard";
          input = "clan-core";
        };
        roles = {
          controller.machines.luffy = {
            settings = {
              endpoint = "nixfp.duckdns.org";
              port = 51820;
            };
          };
          peer.machines = {
            z0r0 = { };
          };
        };
      };

      wifi = {
        module = {
          name = "wifi";
          input = "clan-core";
        };
        roles.default.machines = {
          z0r0 = {
            settings = {
              networks.home = {
                enable = true;
                autoConnect = true;
                keyMgmt = "wpa-psk";
              };
            };
          };
          luffy = {
            settings = {
              networks.home = {
                enable = true;
                autoConnect = true;
                keyMgmt = "wpa-psk";
              };
            };
          };
        };
      };

      nix-cache = {
        module = {
          name = "nix-cache";
          input = "self";
        };
        roles.server.machines.luffy = { };
        roles.client.machines.z0r0 = { };
      };

      sillytavern = {
        module = {
          name = "ai";
          input = "self";
        };
        roles.sillytavern.machines = {
          luffy = { };
        };
      };

      matrix-synapse = {
        module = {
          name = "matrix-synapse";
          input = "clan-core";
        };
        roles.default.machines = {
          luffy = {
            settings = {
              server_tld = "matrix.local";
              app_domain = "element.local";
              acmeEmail = "admin@matrix.local";
              users.t0psh31f = {
                admin = true;
              };
            };
          };
        };
      };

      sshd = {
        module = {
          name = "sshd";
          input = "clan-core";
        };
        roles.server.tags.all = { };
      };
    };
  };

  machines = {
    z0r0 = {
      machine.tags = machinesInventory.z0r0.tags;
      imports = [
        ./machines/z0r0/default.nix
      ]
      ++ mkMachineFromTags machinesInventory.z0r0.tags;
    };

    luffy = {
      machine.tags = machinesInventory.luffy.tags;
      imports = [
        ./machines/luffy/default.nix
      ]
      ++ mkMachineFromTags machinesInventory.luffy.tags;
      clan.services.ai.sillytavern.enable = true;
    };

  };
}
