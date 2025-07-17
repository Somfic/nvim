{ config, pkgs, inputs, lib, ... }:

{
  programs = {
    home-manager = { enable = true; };
    nushell = {
      enable = true;
      shellAliases = {
        "cd" = "z";
        "cd.." = "z ..";
        ".." = "z ..";
        "g" = "git";
        "ll" = "ls -l";
        "cls" = "clear";
        "reload-debug" = "sudo nixos-rebuild switch --flake ~/dot";
        "reload" = "nh os switch ~/dot";
        "update" = "sudo nix flake update --flake ~/dot";
        "clean" = "nh clean all --keep-since 7d";
        "dev rust" = "nix develop ~/dot#rust --command 'nu'";
        "clock" = "termdown -zsf roman";
        "rdev" =
          "nix develop ~/dot # rust -c code .; nix develop ~/dot#rust -c nu";
      };
      settings = { show_banner = false; };
    };
    # carapace = {
    #   enable = true;
    #   enableNushellIntegration = true;
    # };
    starship = {
      enable = true;
      settings = { add_newline = true; };
    };
    zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };
    fastfetch = { enable = true; };
    nh = {
      enable = true;
      clean.enable = true;
      flake = "/home/lucas/dot/flake.nix";
    };
    git = {
      enable = true;
      userEmail = "lucas@somfic.dev";
      userName = "Lucas";
    };
    gh = { enable = true; };
    vscode = { enable = true; };
    kitty = {
      enable = true;
      settings = { window_padding_width = 14; };
    };
    waybar = { enable = true; };
    rofi = { enable = true; };
    direnv = {
      enable = true;
      silent = true;
    };
    lazydocker = { enable = true; };
    firefox = { enable = true; };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    xwayland.enable = true;
    systemd.enable = true;
    settings = {
      "$mod" = "SUPER";
      cursor = {
        inactive_timeout = 10;
        no_hardware_cursors = true;
        hide_on_key_press = false;
      };
      monitor = [
        ", preferred, auto, auto"
        "DP-2, preferred, auto-right, 1"
        "DP-3, preferred, auto-left, 1"
      ];
      general = {
        border_size = 0;
        gaps_in = 7;
        gaps_out = 14;
      };
      decoration = {
        rounding = 15;
        blur = {
          size = 24;
          passes = 3;
          brightness = 0.45;
          vibrancy = 1.0;
          noise = 5.0e-2;
          new_optimizations = true;
          ignore_opacity = true;
        };
        shadow = {
          enabled = true;
          range = 8;
        };
      };
      windowrulev2 = [
        "float,move 10 10,title:^(initialkitty)$"
        "opacity 0.85 override 0.85 override, class:.*"
      ];
      # windowrule = [ "opacity 0.5,class:vesktop" ];
      bindm = [ "$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow" ];
      bind = [
        "$mod, R, exec, rofi -show drun -show-icons"
        "$mod, V, togglefloating"
        "$mod, F, exec, firefox"
        "$mod, C, exec, code"
        "$mod, S, exec, spotify"
        "$mod, D, exec, vesktop"
        "$mod, T, exec, kitty"
        "$mod, J, togglesplit,"
        "$mod, M, exit"

        # moving focus
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # moving windows
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"

        # closing windows
        "$mod, mouse:274, killactive"
        "$mod, Q, killactive"

        ", Print, exec, grimblast copy area"
      ] ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (builtins.genList (i:
          let ws = i + 1;
          in [
            "$mod, code:1${toString i}, workspace, ${toString ws}"
            "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
          ]) 9));

      exec-once = [
        "kitty --title initialkitty -e bash -ic 'fastfetch; exec nu' & waybar"
      ];
    };
  };

  home.file.".envrc" = {
    text = ''
      # auto-detect project type and pick template from your dot flake
      if [ -f Cargo.toml ]; then
        nix develop ~/dot#rust --command nu
      elif [ -f package.json ]; then
        nix develop ~/dot#node --command nu
      fi
    '';
  };

  home.username = "lucas";
  home.homeDirectory = "/home/lucas";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    ffmpeg-full
    vesktop # discord client
    stremio
    google-chrome
    jetbrains.idea-ultimate
    obs-studio
    mprocs # running multiple processes
    termdown # terminal clock
    just # running commands
    spotify
    prismlauncher
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;
}
