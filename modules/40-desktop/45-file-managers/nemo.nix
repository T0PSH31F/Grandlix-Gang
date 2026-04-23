{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    nemo-with-extensions
    nemo-fileroller
    nemo-python
    # image-positioning # This is for MPV, not Nemo.
  ];

  dconf.settings = {
    "org/nemo/preferences" = {
      show-hidden-files = true;
      default-folder-viewer = "list-view";
    };
  };
}
