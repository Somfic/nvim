{ config, pkgs, lib, ... }:

let
  mkEmptyArray = lib.hm.gvariant.mkEmptyArray lib.hm.gvariant.type.string;

  customKeybindingsBase = "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings";
  customKeybindingsPath = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings";

  customBindings = [
    { name = "VS Code"; command = "code"; binding = "<Super>c"; }
    { name = "Spotify"; command = "spotify"; binding = "<Super>s"; }
    { name = "Vesktop"; command = "vesktop"; binding = "<Super>d"; }
    { name = "Terminal"; command = "kitty"; binding = "<Super>t"; }
    { name = "Browser"; command = lib.mkDefault "firefox"; binding = "<Super>f"; }
    { name = "Logout"; command = "gnome-session-quit --logout --no-prompt"; binding = "<Super>m"; }
  ];

  # Generate custom keybinding dconf entries
  customKeybindingEntries = builtins.listToAttrs (lib.imap0 (i: kb: {
    name = "${customKeybindingsPath}/custom${toString i}";
    value = {
      inherit (kb) name command binding;
    };
  }) customBindings);

  # Generate workspace switch/move keybindings and disable conflicting defaults
  workspaceBindings = builtins.listToAttrs (builtins.concatLists (builtins.genList (i:
    let ws = i + 1;
    in [
      { name = "switch-to-workspace-${toString ws}"; value = [ "<Super>${toString ws}" ]; }
      { name = "move-to-workspace-${toString ws}"; value = [ "<Super><Shift>${toString ws}" ]; }
      { name = "switch-to-application-${toString ws}"; value = mkEmptyArray; }
    ]) 9));
  # Script to disable transparency when running under GNOME (no blur backend)
  gnome-fix-transparency = pkgs.writeShellScript "gnome-fix-transparency" ''
    # Replace GTK CSS symlinks with patched copies (no transparency)
    for dir in gtk-3.0 gtk-4.0; do
      css="$HOME/.config/$dir/gtk.css"
      if [ -L "$css" ]; then
        target=$(readlink "$css")
        cp --remove-destination "$target" "$css"
        ${pkgs.gnused}/bin/sed -i '/background: transparent/d' "$css"
      fi
    done

    # Override kitty opacity
    mkdir -p "$HOME/.config/kitty"
    echo "background_opacity 1.0" > "$HOME/.config/kitty/session-override.conf"

    # Override Firefox transparency — replace userChrome/userContent symlinks with opaque versions
    for profile_dir in "$HOME/.mozilla/firefox/"*; do
      [ -d "$profile_dir" ] || continue

      chrome_dir="$profile_dir/chrome"
      [ -d "$chrome_dir" ] || continue

      # Strip transparency from userChrome.css
      if [ -L "$chrome_dir/userChrome.css" ] || [ -f "$chrome_dir/userChrome.css" ]; then
        target="$chrome_dir/userChrome.css"
        [ -L "$target" ] && cp --remove-destination "$(readlink "$target")" "$target"
        ${pkgs.gnused}/bin/sed -i \
          -e '/background-color: transparent/d' \
          -e '/background: transparent/d' \
          -e '/background-image: none/d' \
          -e '/--toolbar-bgcolor: transparent/d' \
          -e '/--lwt-accent-color: transparent/d' \
          "$target"
      fi

      # Remove userContent.css transparent backgrounds
      if [ -L "$chrome_dir/userContent.css" ] || [ -f "$chrome_dir/userContent.css" ]; then
        target="$chrome_dir/userContent.css"
        [ -L "$target" ] && cp --remove-destination "$(readlink "$target")" "$target"
        ${pkgs.gnused}/bin/sed -i \
          -e '/background: transparent/d' \
          "$target"
      fi

      # Override transparency-related prefs in user.js
      userjs="$profile_dir/user.js"
      if [ -L "$userjs" ]; then
        cp --remove-destination "$(readlink "$userjs")" "$userjs"
      fi
      if [ -f "$userjs" ]; then
        ${pkgs.gnused}/bin/sed -i \
          -e 's/user_pref("widget.wayland.opaque-region.enabled", false)/user_pref("widget.wayland.opaque-region.enabled", true)/' \
          -e 's/user_pref("browser.display.background_color", "#00000000")/user_pref("browser.display.background_color", "#1C1B22")/' \
          -e 's/user_pref("browser.display.background_color.dark", "#00000000")/user_pref("browser.display.background_color.dark", "#1C1B22")/' \
          "$userjs"
      fi
    done
  '';
in
{
  home.packages = [
    pkgs.xdg-desktop-portal-gnome  # Needed in user profile for ScreenCast portal
  ];

  # Kitty: include optional session override (silently ignored if missing)
  programs.kitty.extraConfig = ''
    include session-override.conf
  '';

  # Autostart transparency fix in GNOME sessions
  xdg.configFile."autostart/gnome-fix-transparency.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Fix Transparency
    Exec=${gnome-fix-transparency}
    X-GNOME-Autostart-enabled=true
    OnlyShowIn=GNOME;
  '';

  dconf.settings = {
    # Static workspaces (match Hyprland's 1-9 model)
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 9;
    };

    # Register custom keybinding paths
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = builtins.genList
        (i: "${customKeybindingsBase}/custom${toString i}/")
        (builtins.length customBindings);
      screensaver = [ "<Super>l" ];
    };

    # Screenshot
    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = [ "Print" "<Super><Shift>s" ];
      # Disable conflicting defaults
      toggle-quick-settings = mkEmptyArray;
      toggle-message-tray = mkEmptyArray;
      focus-active-notification = mkEmptyArray;
    };

    # Window management + workspaces
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      toggle-fullscreen = [ "<Super><Shift>v" ];
      toggle-above = [ "<Super>v" ];

      # Multi-monitor movement
      move-to-monitor-left = [ "<Super><Shift>Left" ];
      move-to-monitor-right = [ "<Super><Shift>Right" ];
      move-to-workspace-up = [ "<Super><Shift>Up" ];
      move-to-workspace-down = [ "<Super><Shift>Down" ];
    } // workspaceBindings;
  } // customKeybindingEntries;
}
