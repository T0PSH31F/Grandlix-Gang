{ config, lib, ... }:
let
  cfg = config.layers.layer-50.cli;
in
{
  home = lib.mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "hx"; VISUAL = "hx"; PAGER = "bat";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    };

    home.shellAliases = {
      set-ai = "uv run python ~/.local/bin/set-ai";
      GLaDOS = "nix-shell -p portaudio --run \"export LD_LIBRARY_PATH=\\\$(echo \\\$NIX_LDFLAGS | grep -oP '/nix/store/[^ ]+portaudio[^ ]+/lib' | head -n 1); cd ~/Projects/GlaDos/GLaDOS && uv run glados start --input-mode audio\"";
      e = "hx"; edit = "hx"; vi = "hx"; vim = "hx"; v = "hx"; f = "yazi"; fm = "yazi";
      cat = "bat"; ps = "procs"; diff = "delta"; gg = "lazygit"; l = "eza -lh"; ll = "eza -lah"; ls = "eza"; tree = "eza --tree"; serve = "miniserve";
      ".." = "cd .."; "..." = "cd ../.."; "...." = "cd ../../.."; "....." = "cd ../../../..";
      nrs = "sudo nixos-rebuild switch --flake ~/Clan/NFP"; nrt = "sudo nixos-rebuild test --flake ~/Clan/NFP"; nfc = "nix flake check"; nfu = "nix flake update";
      nfp = "clan"; nfpu = "~/Clan/NFP/tools/nfpu/nfpu.sh"; nfps = "clan secrets"; nfpg = "clan vars generate"; cbuild = "clan machines build"; cupdate = "clan machines update";
      htop = "btop"; top = "btop"; weather = "curl wttr.in"; myip = "curl ifconfig.me"; ports = "ss -tulanp"; sysinfo = "fastfetch";
      sex = "xxh root@93.188.162.110"; zshh = "xxh root@";
      vpsu = "ssh t0psh31f@93.188.162.110 '. /etc/profile.d/nix.sh && cd ~/Clan/NFP && git pull && nix run home-manager -- switch --flake .#t0psh31f@vps'";
    };

    programs.zsh.initContent = lib.mkIf cfg.shells.zsh.enable ''
      proj() { local project_dir="$HOME/projects"; if [[ -d "$project_dir" ]]; then cd "$project_dir/$1" 2>/dev/null || cd "$project_dir"; fi; }
      clandir() { local clan_dir="$HOME/Clan"; if [[ -d "$clan_dir" ]]; then cd "$clan_dir/$1" 2>/dev/null || cd "$clan_dir"; fi; }
      ns() { nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history; }
      sshks() { ssh-keyscan -t ed25519 192.168.1.0/24 >> ~/.ssh/known_hosts; }
    '';
  };
}
