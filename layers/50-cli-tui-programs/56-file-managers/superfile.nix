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
    programs.superfile = {
      enable = true;
      metadataPackage = pkgs.exiftool;
      settings = { theme = "aura-theme-dark"; file_panel.show_hidden = true; };
      themes."aura-theme-dark" = {
        code_syntax_highlight = "aura-dark";
        full_screen_fg = "#edecee"; full_screen_bg = "#15141b";
        gradient_color = [ "#a277ff" "#f694ff" ];
        file_panel_fg = "#edecee"; file_panel_bg = "#15141b"; file_panel_border = "#29263c"; file_panel_border_active = "#a277ff"; file_panel_top_directory_icon = "#61ffca"; file_panel_top_path = "#82e2ff"; file_panel_item_selected_fg = "#15141b"; file_panel_item_selected_bg = "#a277ff";
        footer_fg = "#edecee"; footer_bg = "#15141b"; footer_border = "#29263c"; footer_border_active = "#61ffca";
        sidebar_fg = "#edecee"; sidebar_bg = "#15141b"; sidebar_title = "#82e2ff"; sidebar_border = "#15141b"; sidebar_border_active = "#f694ff"; sidebar_item_selected_fg = "#15141b"; sidebar_item_selected_bg = "#f694ff"; sidebar_divider = "#6d6d6d";
        modal_fg = "#edecee"; modal_bg = "#15141b"; modal_border_active = "#6d6d6d"; modal_cancel_fg = "#15141b"; modal_cancel_bg = "#ff6767"; modal_confirm_fg = "#15141b"; modal_confirm_bg = "#61ffca";
        help_menu_hotkey = "#82e2ff"; help_menu_title = "#f694ff";
        cursor = "#a277ff"; correct = "#61ffca"; error = "#ff6767"; hint = "#82e2ff"; cancel = "#ff6767";
      };
      hotkeys = { confirm = [ "enter" "right" "l" ]; cancel = [ "escape" "left" "h" ]; };
      pinnedFolders = [
        { name = "Home"; location = "/home/t0psh31f"; }
        { name = "Downloads"; location = "/home/t0psh31f/Downloads"; }
        { name = "Documents"; location = "/home/t0psh31f/Documents"; }
        { name = "Music"; location = "/home/t0psh31f/Music"; }
        { name = "Pictures"; location = "/home/t0psh31f/Pictures"; }
        { name = "Videos"; location = "/home/t0psh31f/Videos"; }
        { name = "Projects"; location = "/home/t0psh31f/Projects"; }
      ];
    };
    xdg.configFile."superfile/theme/code_syntax_highlight/aura-dark.xml".text = ''
      <style name="aura-dark">
        <entry type="Background" style="bg:#15141b #edecee"/> <entry type="CodeLine" style="#edecee"/> <entry type="Error" style="#ff6767"/> <entry type="Other" style="#edecee"/> <entry type="LineTableTD" style=""/> <entry type="LineTable" style=""/> <entry type="LineHighlight" style="bg:#29263c"/> <entry type="LineNumbersTable" style="#6d6d6d"/> <entry type="LineNumbers" style="#6d6d6d"/>
        <entry type="Keyword" style="#a277ff"/> <entry type="KeywordReserved" style="#a277ff"/> <entry type="KeywordPseudo" style="#a277ff"/> <entry type="KeywordConstant" style="#61ffca"/> <entry type="KeywordDeclaration" style="#a277ff"/> <entry type="KeywordNamespace" style="#a277ff"/> <entry type="KeywordType" style="#82e2ff"/>
        <entry type="Name" style="#edecee"/> <entry type="NameClass" style="#82e2ff"/> <entry type="NameConstant" style="#61ffca"/> <entry type="NameDecorator" style="#f694ff"/> <entry type="NameEntity" style="#ffca85"/> <entry type="NameException" style="#ff6767"/> <entry type="NameFunction" style="#ffca85"/> <entry type="NameFunctionMagic" style="#ffca85"/> <entry type="NameLabel" style="#f694ff"/> <entry type="NameNamespace" style="#edecee"/> <entry type="NameProperty" style="#f694ff"/> <entry type="NameTag" style="#a277ff"/> <entry type="NameVariable" style="#edecee"/> <entry type="NameVariableClass" style="#edecee"/> <entry type="NameVariableGlobal" style="#edecee"/> <entry type="NameVariableInstance" style="#edecee"/> <entry type="NameVariableMagic" style="#edecee"/> <entry type="NameAttribute" style="#f694ff"/> <entry type="NameBuiltin" style="#82e2ff"/> <entry type="NameBuiltinPseudo" style="#82e2ff"/> <entry type="NameOther" style="#edecee"/>
        <entry type="Literal" style="#61ffca"/> <entry type="LiteralDate" style="#61ffca"/> <entry type="LiteralString" style="#61ffca"/> <entry type="LiteralStringChar" style="#61ffca"/> <entry type="LiteralStringSingle" style="#61ffca"/> <entry type="LiteralStringDouble" style="#61ffca"/> <entry type="LiteralStringBacktick" style="#61ffca"/> <entry type="LiteralStringOther" style="#61ffca"/> <entry type="LiteralStringSymbol" style="#61ffca"/> <entry type="LiteralStringInterpol" style="#61ffca"/> <entry type="LiteralStringAffix" style="#a277ff"/> <entry type="LiteralStringDelimiter" style="#61ffca"/> <entry type="LiteralStringEscape" style="#a277ff"/> <entry type="LiteralStringRegex" style="#61ffca"/> <entry type="LiteralStringDoc" style="#6d6d6d"/> <entry type="LiteralStringHeredoc" style="#6d6d6d"/> <entry type="LiteralNumber" style="#61ffca"/> <entry type="LiteralNumberBin" style="#61ffca"/> <entry type="LiteralNumberHex" style="#61ffca"/> <entry type="LiteralNumberInteger" style="#61ffca"/> <entry type="LiteralNumberFloat" style="#61ffca"/> <entry type="LiteralNumberIntegerLong" style="#61ffca"/> <entry type="LiteralNumberOct" style="#61ffca"/>
        <entry type="Operator" style="#a277ff"/> <entry type="OperatorWord" style="#a277ff"/>
        <entry type="Comment" style="italic #6d6d6d"/> <entry type="CommentSingle" style="italic #6d6d6d"/> <entry type="CommentMultiline" style="italic #6d6d6d"/> <entry type="CommentSpecial" style="italic #6d6d6d"/> <entry type="CommentHashbang" style="italic #6d6d6d"/> <entry type="CommentPreproc" style="italic #6d6d6d"/> <entry type="CommentPreprocFile" style="italic #6d6d6d"/>
        <entry type="Generic" style="#edecee"/> <entry type="GenericInserted" style="bg:#15141b #61ffca"/> <entry type="GenericDeleted" style="bg:#15141b #ff6767"/> <entry type="GenericEmph" style="italic #edecee"/> <entry type="GenericStrong" style="bold #edecee"/> <entry type="GenericUnderline" style="underline #edecee"/> <entry type="GenericHeading" style="bold #a277ff"/> <entry type="GenericSubheading" style="bold #a277ff"/> <entry type="GenericOutput" style="#edecee"/> <entry type="GenericPrompt" style="#edecee"/> <entry type="GenericError" style="#ff6767"/> <entry type="GenericTraceback" style="#ff6767"/>
        <entry type="Punctuation" style="#f694ff"/> <entry type="Text" style="#edecee"/> <entry type="TextWhitespace" style="#edecee"/>
      </style>
    '';
  };
}
