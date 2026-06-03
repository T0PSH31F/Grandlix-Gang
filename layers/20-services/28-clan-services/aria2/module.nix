{
  _class = "clan.service";
  manifest.name = "media";
  manifest.readme = "Media services including download managers";

  roles = {
    aria2 = {
      perInstance.nixosModule = ../../23-media/download-clients.nix;
      description = "Aria2: High-speed download manager with RPC support";
    };
  };
}
