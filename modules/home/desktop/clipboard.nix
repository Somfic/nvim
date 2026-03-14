{ config, pkgs, ... }:

let
  # Clipboard history rofi integration script
  clipboard-rofi = pkgs.writeShellScriptBin "clipboard-rofi" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Check if cliphist has any history
    HISTORY_COUNT=$(${pkgs.cliphist}/bin/cliphist list | wc -l)

    if [ "$HISTORY_COUNT" -eq 0 ]; then
      ${pkgs.libnotify}/bin/notify-send "📋 Clipboard" "No clipboard history" -u normal
      exit 0
    fi

    # Show clipboard history in rofi
    SELECTED=$(${pkgs.cliphist}/bin/cliphist list | \
      ${pkgs.rofi}/bin/rofi -dmenu -i -p "📋 Clipboard History" \
      -theme-str 'window {width: 70%;}' \
      -theme-str 'listview {lines: 15;}')

    if [ -z "$SELECTED" ]; then
      exit 0
    fi

    # Decode and copy the selected item to clipboard
    echo "$SELECTED" | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy

    ${pkgs.libnotify}/bin/notify-send "📋 Clipboard" "Copied to clipboard" -u low
  '';

  # Clear clipboard history script
  clipboard-clear = pkgs.writeShellScriptBin "clipboard-clear" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Ask for confirmation
    CONFIRM=$(echo -e "Yes\nNo" | ${pkgs.rofi}/bin/rofi -dmenu -i -p "Clear clipboard history?" \
      -theme-str 'window {width: 25%;}')

    if [ "$CONFIRM" = "Yes" ]; then
      ${pkgs.cliphist}/bin/cliphist wipe
      ${pkgs.wl-clipboard}/bin/wl-copy -c  # Clear current clipboard
      ${pkgs.libnotify}/bin/notify-send "📋 Clipboard" "Clipboard history cleared" -u low
    fi
  '';

in {
  home.packages = with pkgs; [
    cliphist
    wl-clipboard
    clipboard-rofi
    clipboard-clear
  ];

  # Start cliphist store on login via systemd user services
  # Compositor-agnostic: works for both Hyprland and Niri
  systemd.user.services.cliphist-text = {
    Unit = {
      Description = "Clipboard history watcher (text)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store'";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.cliphist-image = {
    Unit = {
      Description = "Clipboard history watcher (images)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store'";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
