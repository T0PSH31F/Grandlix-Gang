{
  description = "Hermes Agent container — portable OCI image with gateway, dashboard, and web UI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        hermesVersion = "0.17.0";

        entrypoint = pkgs.writeShellScriptBin "entrypoint" (builtins.readFile ./entrypoint.sh);

        baseLayer = pkgs.buildEnv {
          name = "hermes-base";
          paths = with pkgs; [
            python3
            python3.pkgs.pip
            python3.pkgs.setuptools
            python3.pkgs.wheel
            nodejs
            git
            ripgrep
            ffmpeg
            curl
            cacert
            entrypoint
          ];
          pathsToLink = [
            "/bin"
            "/lib"
            "/etc"
            "/libexec"
          ];
          ignoreCollisions = true;
        };

        containerImage = pkgs.dockerTools.buildImage {
          name = "hermes-agent";
          tag = hermesVersion;

          copyToRoot = baseLayer;

          runAsRoot = ''
            #!${pkgs.runtimeShell}
            set -euo pipefail

            export HOME=/root
            export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

            echo "Installing Hermes Agent ${hermesVersion}..."
            pip3 install "hermes-agent[cli]==${hermesVersion}" --no-cache-dir --break-system-packages

            echo "Cloning hermes-webui..."
            git clone --depth 1 https://github.com/nesquena/hermes-webui /opt/hermes-webui

            echo "Installing webui Python deps..."
            pip3 install pyyaml cryptography --no-cache-dir --break-system-packages

            mkdir -p /data /config
            chmod 755 /entrypoint/bin/entrypoint
          '';

          config = {
            Cmd = [ "/entrypoint/bin/entrypoint" ];
            ExposedPorts = {
              "8642/tcp" = { };
              "3000/tcp" = { };
              "9119/tcp" = { };
            };
            Volumes = {
              "/data" = { };
              "/config" = { };
            };
            Env = [
              "HERMES_HOME=/data"
              "HERMES_CONFIG_PATH=/data/config.yaml"
              "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            ];
          };
        };
      in
      {
        packages.hermes-container = containerImage;
        packages.default = containerImage;

        apps.hermes-container = {
          type = "app";
          program = "${containerImage}/bin/load-image";
        };

        devShells.default = pkgs.mkShell {
          name = "hermes-container-dev";
          buildInputs = with pkgs; [ dockerTools ];
        };
      }
    );
}
