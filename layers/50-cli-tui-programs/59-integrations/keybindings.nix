{
  config,
  lib,
  ...
}:
let
  cfg = config.layers.layer-50.cli;
in
{
  home = lib.mkIf cfg.enable {
    programs.zsh.initContent = lib.mkIf cfg.shells.zsh.enable ''
      fzf-cd() { local dir; dir=$(fd --type d --hidden --exclude .git | fzf --preview 'eza --tree --level=1 --icons {}'); if [[ -n "$dir" ]]; then cd "$dir"; zle reset-prompt; fi; }
      zle -N fzf-cd
      bindkey '^F' fzf-cd
      fzf-edit() { local file; file=$(fd --type f --hidden --exclude .git | fzf --preview 'bat --color=always {}'); if [[ -n "$file" ]]; then hx "$file"; fi; }
      zle -N fzf-edit
      bindkey '^E' fzf-edit
    '';
  };
}
