{
  imports = [
    # ./clan-service-modules/default.nix # Removed due to class mismatch (clan.service vs clan)
  ];

  meta.name = "NFP";

  inventory = {
    machines = {
      z0r0 = {
        tags = [
          "workstation"
          "desktop"
          "development"
          "gaming"
        ];
        deploy.targetHost = "root@z0r0.local";
      };
      nami = {
        tags = [
          "workstation"
          "laptop"
          "desktop"
          "media"
        ];
        deploy.targetHost = "root@nami.local";
      };
      luffy = {
        tags = [
          "server"
          "gpu-compute"
          "ai"
        ];
        # deploy.targetHost = "root@luffy.local";
      };
      # nami = {
      #   tags = [
      #     "server"
      #     "media-server"
      #     "download-server"
      #   ];
      #   deploy.targetHost = "root@nami.local";
      # };

    };

    instances = {
      /*
        zerotier = {
          module = {
            name = "zerotier";
            input = "clan-core";
          };
          # roles.controller.machines.luffy = { };
          # roles.moon.machines."luffy".settings.stableEndpoints = [
          #   "93.188.162.110"
          #   "93.188.162.110/9993"
          # ];
          roles.peer.machines = {
            z0r0 = { };
            nami = { };

          };
        };
      */

      # nix-cache = {
      #   module = {
      #     name = "nix-cache";
      #     input = "self";
      #   };

      #   roles.client.machines = {
      #     z0r0 = { };
      #     nami = { };

      #   };
      # };

      sillytavern = {
        module = {
          name = "ai";
          input = "self";
        };
        roles.sillytavern.machines = {
          z0r0 = { };

        };
      };
    };
  };

  machines = {
    z0r0 = {
      imports = [
        ./machines/z0r0/default.nix
      ];
      clan.services.ai.sillytavern.enable = true;
    };
    nami = {
      imports = [
        ./machines/nami/default.nix
      ];
    };
    luffy = {
      imports = [
        ./machines/luffy/default.nix
      ];
    };

  };
}
