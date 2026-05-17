{
  description = "Nix Flake Pirates (NFP) Configuration";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org"
      "https://cache.numtide.com"
      "https://numtide.cachix.org"
      "https://vicinae.cachix.org"
      "https://hyprland.cachix.org"
      "https://niri.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "numtide.cachix.org-1:vSxzZPSh9OCpqJc572Mk9BdbrGMNSbR4F5O4/jVtHK8="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    clan-core = {
      url = "git+https://git.clan.lol/clan/clan-core";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.sops-nix.follows = "sops-nix";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland";
    };
    # hyprland-plugins = {
    #   url = "github:hyprwm/hyprland-plugins";
    #   inputs.hyprland.follows = "hyprland";
    # };
    # hyprspace = {
    #   url = "github:KZDKM/Hyprspace";
    #   inputs.hyprland.follows = "hyprland";
    # };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixai = {
      url = "github:olafkfreund/nix-ai-help";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules = {
      url = "github:numtide/nixos-facter-modules";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.vicinae.follows = "vicinae";
    };
    yazelix-hm = {
      url = "github:luccahuguet/yazelix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wakatime-lsp = {
      url = "github:mrnossiom/wakatime-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    antigravity = {
      url = "github:Jacopone/Antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      clan-core,
      flake-parts,
      home-manager,
      import-tree,
      llm-agents,
      niri,
      noctalia,
      spicetify-nix,
      stylix,
      vicinae,
      vicinae-extensions,
      nixai,
      yazelix-hm,
      disko,
      wakatime-lsp,
      antigravity,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        config,
        inputs,
        ...
      }:
      {
        imports = [
          clan-core.flakeModules.default
          home-manager.flakeModules.home-manager
          ./layers/00-cyberia/07-clan/clan-inventory.nix
        ];

        clan = {
          imports = [ ./clan.nix ];
          specialArgs = {
            inherit inputs;
          };
          # Configure nixpkgs to allow unfree packages
          pkgsForSystem =
            system:
            import inputs.nixpkgs {
              localSystem = system;
              config.allowUnfree = true;
              overlays = [
                (import ./layers/80-lib/82-overlays/custom-packages.nix)
              ];
            };
        };

        # Register clan services from new structure
        flake.clan = {
          modules = {
            # AI services
            ai = ./layers/20-services/28-clan-services/sillytavern/module.nix;

            # Desktop/Infrastructure services bundle
            desktop = ./layers/20-services/28-clan-services/homepage-dashboard/module.nix;

            # Media services
            media = ./layers/20-services/28-clan-services/aria2/module.nix;

            # Binary cache
            nix-cache = ./layers/20-services/28-clan-services/nix-cache/default.nix;
          };
        };

        systems = [ "x86_64-linux" ];

        flake.homeConfigurations = {
          "root@vps" = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import inputs.nixpkgs {
              system = "x86_64-linux";
              config.allowUnfree = true;
              overlays = [
                (import ./layers/80-lib/82-overlays/custom-packages.nix)
              ];
            };
            extraSpecialArgs = { inherit inputs; };
            modules = [
              ./layers/50-cli-tui-programs/50-entry/cli-tui.nix
              {
                home.username = "root";
                home.homeDirectory = "/root";
                # Standard age key location for NFP users
                sops.age.keyFile = "/root/.config/sops/age/keys.txt";
                # Enable Yazelix on VPS
                programs.cli-environment.headless = true;
                programs.cli-environment.theming.theme = "Tokyo Night Moon";
                features.home.cli.yazelix.enable = true;
              }
            ];
          };
        };

        perSystem =
          {
            pkgs,
            system,
            ...
          }:
          {
            _module.args.pkgs = import inputs.nixpkgs {
              localSystem = system;
              config.allowUnfree = true;
              overlays = [
              ];
            };
            packages.iso =
              (inputs.nixpkgs.lib.nixosSystem {
                inherit system;
                specialArgs = { inherit inputs; };
                modules = [
                  ./layers/00-cyberia/04-templates/iso/default.nix
                ];
              }).config.system.build.isoImage;

            devShells.default = pkgs.mkShell {
              packages = with pkgs; [
                clan-core.packages.${system}.clan-cli
                curl
                deadnix
                git
                nil
                nixd
                nix-fast-build
                nix-search-cli
                nix-top
                nixel
                nixfmt
                nixfmt-tree
                nixpkgs-pytools
                statix
              ];

              shellHook = ''
                                cat << 'EOF'
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⢿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⣀⣼⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⡗⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⡈⣇⠀⠀⠀⢀⣠⣴⣶⠿⢿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⣀⣇⣀⡀⠀⠀⠀⠀⠀⠀⣄⣤⡾⠿⡻⣿⣿⣿⣶⠾⠛⠋⠁⠀⠀⢸⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⠛⠿⠟⢻⣷⡄⠀⣀⣦⠶⠛⠉⠁⠀⠀⢹⠿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣶⣿⣷⣾⣯⡿⡟⠉⠀⠀⠀⠀⠀⠀⠀⠀⢃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣩⣿⠿⠋⢡⠊⣻⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⠿⠛⠉⠀⢀⣴⡵⠊⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢱⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⠟⢻⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⡾⢿⠏⠁⡠⠒⣉⣹⣾⣏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢇⠀⠀⢆⠀⠀⣇⠀⠀⢸⡏⡍⠀⢸⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠰⡿⠛⠁⣴⡅⢣⣾⣲⣿⡿⠿⡟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠇⢀⣨⣤⣶⣾⣾⣟⣿⣿⡇⣀⣼
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠇⠀⠀⢀⣼⣾⣷⠋⡟⢱⣰⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⡿⣿⠛⣿⠉⡟⠀⡏⠈⡇⠙⢻⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⢠⠀⠀⠀⠊⢹⡞⣸⣘⠥⣻⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢣⡏⠀⡇⠀⡇⠀⢳⠀⢇⠀⣸⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠘⣍⠙⣏⣼⡍⠢⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣷⠀⢹⡀⢿⢀⣸⣆⣾⣽⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣄⢠⡠⠤⣄⣸⡀⠀⠀⠀⡸⣿⡯⣷⣯⡟⠦⡈⠲⣄⣠⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣼⣼⣧⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⣿⢿⢟⠟⢠⡴⠈⢿⡇⠀⠀⢰⢣⠻⡉⠉⢀⠇⠀⠌⠳⡄⢀⡽⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⠿⠿⣟⢷⣶⠏⡼⣲⣶⢸⣧⣄⢸⣷⣤⣌⣉⣙⣒⣋⠻⠥⢀⣀⡘⠀⢙⣶⣇⡀⣤⠤⠤⢤⡄⠤⣀⣀⣀⠀⠀⠀⠀⣿⣿⣟⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⡿⠟⢋⢰⣿⠇⠀⠸⣅⣼⠟⡿⡃⢀⣿⡿⢸⣿⣦⡟⢁⡀⢀⡸⡙⣿⣷⣶⠉⠻⠿⠿⢿⣰⠁⡎⠉⢢⠹⡀⠈⠻⣿⣷⡄⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⠂⠀⣾⠀⠀⠀⢰⣴⡿⢛⣾⣣⣿⡟⣻⡀⢋⣿⣿⡄⢻⡇⢸⡇⣀⣿⣿⡏⢀⣦⣤⣤⣤⣘⣦⣉⣁⡼⢠⣇⠀⣀⣧⣿⣿⡀⠀⣿⠏⢠⣏⣿⠛⢿⣿⣿
                ⣿⣿⣿⣦⡤⠃⠀⠀⢠⣿⠀⢠⣾⣿⣿⣿⠷⡿⠇⣿⠿⢿⣿⣿⣇⢼⣿⢹⣿⡟⢀⣼⣿⣧⡿⣿⣿⣿⡄⢠⢶⣿⣿⡿⠿⠿⠿⠟⠧⢸⣿⣿⣿⣿⣿⣶⣿
                ⣿⣿⣿⣿⣿⣦⡐⢠⡯⠼⣶⣿⣿⣿⣿⡏⠀⠀⣸⣿⣶⣦⣤⣍⣙⠛⠻⠿⠿⠀⡞⢻⣿⣿⣿⣿⣿⣿⣷⠘⡞⣿⣿⣿⣄⣠⣾⡧⠀⠤⡟⢓⠷⠽⣦⣭⣓⠿
                ⣿⣿⣿⣿⣿⡟⠅⣠⡳⠀⣨⣿⣟⢻⣟⣔⡆⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⣼⡁⠸⣿⣿⣿⣭⣿⣿⣿⡄⢱⣘⣿⣿⣿⣯⣡⣿⠇⠀⡇⣸⠉⠓⣶⢸⣿⣿
                ⣿⣿⣿⣿⣿⣿⣾⠟⣹⡋⣿⡆⢹⠿⣄⠛⣣⣿⣿⣿⠁⣾⣿⣿⣿⣿⡟⠀⣼⣿⣷⣆⢻⣿⣿⣯⣾⣿⣿⣿⡄⠉⢽⣿⣿⣿⣿⢽⢴⡶⠁⣯⣶⡆⣿⡍⠙⢻
                ⣿⣿⣿⣿⣿⡏⠀⣼⡿⠿⡾⣿⠀⢀⡼⣼⣿⣿⣿⣿⣿⣬⣽⣿⣿⠟⢀⣾⣿⣿⣿⣜⡌⢿⣿⣿⣿⣿⣻⢿⣿⣄⣠⢿⣾⣿⣿⣷⡊⠁⣼⣛⠿⢿⡇⣿⣿⣿
                ⣿⣿⣿⣿⣿⣧⣴⣿⣿⠓⣾⡧⡴⣏⣿⣿⣷⣌⡙⠻⣿⣿⣿⣿⠋⣠⣿⣿⣿⣿⣿⣿⣿⣆⠻⣿⣿⣮⣯⣾⣿⡿⠱⢿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣾⢹⣿⣇⣈
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣬⣤⣾⣿⣿⠛⠻⣿⣿⣷⣦⣭⠙⢁⣴⣿⣿⣧⡝⠿⣿⣿⣿⣿⣧⡙⠿⣿⣿⣿⣿⡇⠀⠚⣿⡏⠹⣿⣿⣾⣿⣿⡿⢣⣶⣤⣭⣍
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣷⣽⣿⣷⣤⡼⣿⡿⠛⠁⣠⠾⠿⣿⣿⣿⣿⣦⣈⠻⣿⣿⣿⣷⣄⡈⠙⠿⣿⡇⠀⢒⣿⡇⠀⣿⣿⣿⡿⠟⣡⣿⣾⣿⣯⣽
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⡛⢻⡛⠛⠉⢀⣤⠞⠙⡏⠙⠻⣿⣿⣿⣿⣿⣿⣷⣌⡙⠿⣿⣿⣿⣷⣾⣿⣷⡂⢘⣿⡇⠀⣿⣿⣿⣴⣊⣉⣿⠟⣷⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠻⣗⢺⣿⣏⠀⠀⠀⠁⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿⣶⣤⣉⣿⣿⣿⣿⣿⣷⠛⣛⠛⣶⣿⣿⣃⣠⠴⠚⢁⣴⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠈⠳⠙⢿⣿⣄⠀⠀⠐⣲⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣾⣿⣿⡿⠯⢐⣦⣵⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠙⠻⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡷⣶⣖⣉⣹⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠈⠙⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠟⠉⠁⠀⢈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠛⠿⠿⣿⣿⣿⣿⣿⣿⣿⣯⣭⣤⣀⣀⠀⠀⠀⣰⣿⣿⠍⣿⣿⣿⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣠⣤⣶⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣿⣿⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿
                EOF
                                echo "Nix Flake Pirates Configuration"
                                echo "==================================="
                                echo ""
                                echo "NOTE: Development environments have been moved to T0PSH31F/grandlix-devenvs"
                                echo ""
                                echo "Quick start:"
                                echo "  nix develop github:T0PSH31F/grandlix-devenvs#python-ai-agent"
                                echo ""
              '';
            };

            # Image generation outputs using nixos-generators removed
            checks =
              let
                theme-tests = import ./layers/00-cyberia/05-tests/themes.nix {
                  inherit pkgs;
                  lib = pkgs.lib;
                };
              in
              {
                inherit (theme-tests) plymouth-theme-builds sddm-theme-builds all-themes;

                services-test = pkgs.testers.nixosTest (import ./layers/00-cyberia/05-tests/services.nix);
                n8n-test = pkgs.testers.nixosTest (import ./layers/00-cyberia/05-tests/n8n.nix);
              };
          };
      }
    );
}
