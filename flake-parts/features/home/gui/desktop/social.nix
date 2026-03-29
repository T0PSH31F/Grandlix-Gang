{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    # Communication
    beeper
    beeper-bridge-manager
    signal-desktop
    # kotatogram-desktop # Telegram client
    ayugram-desktop # Telegram client (alternative)
    tdl # Telegram downloader/tool
    element-desktop # Matrix client
    vesktop # Discord client (Vencord)
    equibop # Discord client (alternative)
    caprine # Facebook Messenger
  ];
}
