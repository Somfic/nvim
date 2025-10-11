{ config, pkgs, ... }:

let
  # Passbolt rofi integration script
  passbolt-rofi = pkgs.writeShellScriptBin "passbolt-rofi" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # List all resources in table format (MUCH faster - no decryption!)
    RESOURCES=$(passbolt list resource --column ID --column Name --column Username 2>&1)

    # Check if there was an error (not configured)
    if echo "$RESOURCES" | grep -q "Error"; then
      ${pkgs.libnotify}/bin/notify-send "Passbolt" "Not configured. Run: passbolt configure" -u critical
      exit 1
    fi

    if [ -z "$RESOURCES" ]; then
      ${pkgs.libnotify}/bin/notify-send "Passbolt" "No resources found" -u normal
      exit 0
    fi

    # Parse table format and show in rofi (skip header line)
    SELECTED=$(echo "$RESOURCES" | tail -n +2 | ${pkgs.gawk}/bin/awk -F'|' '{
      gsub(/^[ \t]+|[ \t]+$/, "", $1);  # trim ID
      gsub(/^[ \t]+|[ \t]+$/, "", $2);  # trim Name
      gsub(/^[ \t]+|[ \t]+$/, "", $3);  # trim Username
      printf "%s | %s [%s]\n", $2, $3, $1
    }' | ${pkgs.rofi}/bin/rofi -dmenu -i -p "🔐 Password" -theme-str 'window {width: 60%;}')

    if [ -z "$SELECTED" ]; then
      exit 0
    fi

    # Extract the ID and username from selection
    ID=$(echo "$SELECTED" | grep -oP '\[\K[^\]]+')
    USERNAME=$(echo "$SELECTED" | ${pkgs.gnused}/bin/sed -n 's/^.* | \(.*\) \[.*\]$/\1/p')

    # Show action menu
    ACTION=$(echo -e "📋 Copy Username\n🔑 Copy Password\n📋🔑 Copy Both" | \
      ${pkgs.rofi}/bin/rofi -dmenu -i -p "Action" -theme-str 'window {width: 25%;}')

    case "$ACTION" in
      *"Username"*)
        echo -n "$USERNAME" | ${pkgs.wl-clipboard}/bin/wl-copy
        ${pkgs.libnotify}/bin/notify-send "Passbolt" "Username copied: $USERNAME" -u low
        ;;
      *"Password"*)
        # Only NOW decrypt the password for the selected resource
        ${pkgs.libnotify}/bin/notify-send "Passbolt" "Decrypting password..." -u low -t 1000
        PASSWORD=$(passbolt get resource --id "$ID" --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.password')
        echo -n "$PASSWORD" | ${pkgs.wl-clipboard}/bin/wl-copy
        ${pkgs.libnotify}/bin/notify-send "Passbolt" "Password copied to clipboard" -u low
        ;;
      *"Both"*)
        # Decrypt password for both
        ${pkgs.libnotify}/bin/notify-send "Passbolt" "Decrypting password..." -u low -t 1000
        PASSWORD=$(passbolt get resource --id "$ID" --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.password')

        # Copy username first
        echo -n "$USERNAME" | ${pkgs.wl-clipboard}/bin/wl-copy
        ${pkgs.libnotify}/bin/notify-send "Passbolt" "Username copied: $USERNAME\nPassword in 2s..." -u low

        # Wait 2 seconds then copy password
        sleep 2
        echo -n "$PASSWORD" | ${pkgs.wl-clipboard}/bin/wl-copy
        ${pkgs.libnotify}/bin/notify-send "Passbolt" "Password copied to clipboard" -u low
        ;;
    esac
  '';

in {
  home.packages = with pkgs; [
    rofi
    go-passbolt-cli
    passbolt-rofi
    wl-clipboard
    libnotify
    jq
    gawk
    gnused
  ];

  # Custom rofi theme for password manager
  home.file.".config/rofi/passbolt.rasi".text = ''
    * {
      bg: #1e1e2e;
      bg-alt: #313244;
      fg: #cdd6f4;
      fg-alt: #bac2de;

      accent: #89b4fa;
      urgent: #f38ba8;

      border-color: @accent;
      background-color: @bg;
      text-color: @fg;

      font: "JetBrainsMono Nerd Font 12";
    }

    window {
      transparency: "real";
      background-color: @bg;
      border: 2px;
      border-color: @accent;
      border-radius: 12px;
      padding: 20px;
      width: 600px;
    }

    mainbox {
      background-color: transparent;
      children: [ inputbar, listview ];
      spacing: 15px;
    }

    inputbar {
      background-color: @bg-alt;
      text-color: @fg;
      border: 0px;
      border-radius: 8px;
      padding: 12px 16px;
      children: [ prompt, entry ];
      spacing: 10px;
    }

    prompt {
      background-color: transparent;
      text-color: @accent;
      font: "JetBrainsMono Nerd Font Bold 12";
    }

    entry {
      background-color: transparent;
      text-color: @fg;
      placeholder: "Search...";
      placeholder-color: @fg-alt;
    }

    listview {
      background-color: transparent;
      columns: 1;
      lines: 8;
      spacing: 5px;
      cycle: false;
      dynamic: true;
      layout: vertical;
    }

    element {
      background-color: transparent;
      text-color: @fg;
      border-radius: 6px;
      padding: 8px 12px;
    }

    element selected {
      background-color: @accent;
      text-color: @bg;
    }

    element-text {
      background-color: transparent;
      text-color: inherit;
    }

    element-icon {
      background-color: transparent;
      size: 24px;
      padding: 0px 8px 0px 0px;
    }
  '';
}
