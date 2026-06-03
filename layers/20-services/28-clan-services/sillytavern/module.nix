{
  _class = "clan.service";
  manifest.name = "ai";
  manifest.readme = "AI services and frontends";

  roles = {
    sillytavern = {
      perInstance.nixosModule = ../../22-ai/sillytavern.nix;
      description = "SillyTavern: AI chat frontend";
    };
  };
}
