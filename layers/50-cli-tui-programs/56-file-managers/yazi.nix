{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.cli;
in
{
  home = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
      enableZshIntegration = true;
      plugins = with pkgs.yaziPlugins; {
        bookmarks = bookmarks; chmod = chmod; compress = compress; ouch = ouch;
        rsync = rsync; sudo = sudo; diff = diff; drag = drag; dupes = dupes;
        full-border = full-border; gitui = gitui; lazygit = lazygit; glow = glow;
        mediainfo = mediainfo; mime-ext = mime-ext; rich-preview = rich-preview;
        piper = piper; gvfs = gvfs; recycle-bin = recycle-bin; vcs-files = vcs-files;
        wl-clipboard = wl-clipboard; yatline = yatline; yatline-githead = yatline-githead;
      };
      settings = {
        manager = { show_hidden = true; sort_by = "natural"; sort_dir_first = true; };
        opener.edit = [ { run = ''${pkgs.helix}/bin/hx "$@"''; block = true; } ];
      };
      keymap.manager.prepend_keymap = [
        { on = [ "e" ]; run = "open"; desc = "Open with Helix"; }
        { on = [ "<C-s>" ]; run = "escape"; desc = "Exit yazi"; }
        { on = [ "b" "a" ]; run = "plugin bookmarks save"; desc = "Add bookmark"; }
        { on = [ "b" "g" ]; run = "plugin bookmarks jump"; desc = "Jump to bookmark"; }
        { on = [ "b" "d" ]; run = "plugin bookmarks delete"; desc = "Delete bookmark"; }
        { on = [ "C" ]; run = "plugin compress"; desc = "Compress selected files"; }
        { on = [ "D" ]; run = "plugin diff"; desc = "Diff selected files"; }
        { on = [ "c" "m" ]; run = "plugin chmod"; desc = "Change file permissions"; }
        { on = [ "g" "u" ]; run = "plugin gitui"; desc = "Open GitUI"; }
        { on = [ "g" "l" ]; run = "plugin lazygit"; desc = "Open Lazygit"; }
        { on = [ "d" "t" ]; run = "plugin recycle-bin delete"; desc = "Move to recycle bin"; }
        { on = [ "d" "r" ]; run = "plugin recycle-bin restore"; desc = "Restore from recycle bin"; }
        { on = [ "y" "c" ]; run = "plugin wl-clipboard"; desc = "Copy to Wayland clipboard"; }
      ];
    };
  };
}
