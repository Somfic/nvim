{ config, pkgs, ... }:

{
  programs = {
    vscode.enable = true;
    firefox.enable = true;

    kitty = {
      enable = true;
      settings = { window_padding_width = 14; };
    };

    waybar.enable = true;

    rofi = {
      enable = true;
      terminal = "${pkgs.kitty}/bin/kitty";

      extraConfig = {
        modi = "drun,run,window,ssh";
        show-icons = true;
        icon-theme = "Papirus";
        display-drun = "Apps";
        display-run = "Run";
        display-window = "Windows";
        display-ssh = "SSH";
        drun-display-format = "{name}";
        window-format = "{w} · {c} · {t}";
        disable-history = false;
        sort = true;
        sorting-method = "fzf";
        case-sensitive = false;
        cycle = true;
        sidebar-mode = false;
        hover-select = true;
        eh = 1;
        auto-select = false;
        parse-hosts = true;
        parse-known-hosts = true;
        matching = "fuzzy";
        scroll-method = 0;
        normalize-match = true;
        steal-focus = true;
        application-fallback-icon = "application-x-executable";
        pid = "/run/user/1000/rofi.pid";
        kb-cancel = "Escape,Control+g,Control+bracketleft";
        kb-accept-entry = "Control+j,Control+m,Return,KP_Enter";
        kb-row-up = "Up,Control+p";
        kb-row-down = "Down,Control+n";
        kb-mode-previous = "Shift+Left";
        kb-element-prev = "Shift+Tab";
      };
    };
  };

  # Configure rofi theme files
  home.file.".config/rofi/shared/colors.rasi".source = ./rofi-colors.rasi;
  home.file.".config/rofi/shared/fonts.rasi".source = ./rofi-fonts.rasi;
  home.file.".config/rofi/fullscreen.rasi".source = ./rofi-fullscreen.rasi;
  home.file.".config/rofi/adi1090x-type3-style3.rasi".source =
    ./adi1090x-type3-style3.rasi;
}
