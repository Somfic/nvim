{ config, pkgs, ... }:

let
  # VPN rofi integration script
  vpn-rofi = pkgs.writeShellScriptBin "vpn-rofi" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Get current VPN connection status
    CURRENT_VPN=$(${pkgs.networkmanager}/bin/nmcli -t -f NAME,TYPE,STATE connection show --active | \
      ${pkgs.gawk}/bin/awk -F: '$2=="vpn" && $3=="activated" {print $1}')

    # List all VPN connections
    VPN_LIST=$(${pkgs.networkmanager}/bin/nmcli -t -f NAME,TYPE connection show | \
      ${pkgs.gawk}/bin/awk -F: '$2=="vpn" {print $1}')

    if [ -z "$VPN_LIST" ]; then
      ${pkgs.libnotify}/bin/notify-send "VPN" "No VPN connections configured" -u normal
      exit 0
    fi

    # Build menu with current status
    MENU="Disconnect VPN"
    if [ -z "$CURRENT_VPN" ]; then
      MENU="$MENU (No VPN active)"
    else
      MENU="$MENU (Currently: $CURRENT_VPN)"
    fi

    # Add separator
    MENU="$MENU\n---"

    # Add VPN connections with indicator for active one
    while IFS= read -r vpn; do
      if [ "$vpn" = "$CURRENT_VPN" ]; then
        MENU="$MENU\n✓ $vpn"
      else
        MENU="$MENU\n  $vpn"
      fi
    done <<< "$VPN_LIST"

    # Show rofi menu
    SELECTED=$(echo -e "$MENU" | ${pkgs.rofi}/bin/rofi -dmenu -i -p "VPN" \
      -theme-str 'window {width: 40%;}' \
      -theme-str 'listview {lines: 10;}')

    if [ -z "$SELECTED" ]; then
      exit 0
    fi

    # Handle selection
    if echo "$SELECTED" | grep -q "Disconnect VPN"; then
      if [ -n "$CURRENT_VPN" ]; then
        ${pkgs.libnotify}/bin/notify-send "VPN" "Disconnecting from $CURRENT_VPN..." -u low
        ${pkgs.networkmanager}/bin/nmcli connection down "$CURRENT_VPN"
        ${pkgs.libnotify}/bin/notify-send "VPN" "Disconnected" -u low
      else
        ${pkgs.libnotify}/bin/notify-send "VPN" "No VPN to disconnect" -u low
      fi
    elif ! echo "$SELECTED" | grep -q "^---"; then
      # Extract VPN name (remove checkmark and leading spaces)
      VPN_NAME=$(echo "$SELECTED" | ${pkgs.gnused}/bin/sed 's/^[✓ ]*//')

      if [ "$VPN_NAME" != "$CURRENT_VPN" ]; then
        ${pkgs.libnotify}/bin/notify-send "VPN" "Connecting to $VPN_NAME..." -u low

        # Disconnect current VPN if any
        if [ -n "$CURRENT_VPN" ]; then
          ${pkgs.networkmanager}/bin/nmcli connection down "$CURRENT_VPN" 2>/dev/null || true
        fi

        # Try to connect to selected VPN
        # First attempt without credentials (works if stored)
        CONNECT_OUTPUT=$(${pkgs.networkmanager}/bin/nmcli connection up "$VPN_NAME" 2>&1)
        if ! echo "$CONNECT_OUTPUT" | grep -q "successfully activated"; then
          # Connection failed, likely needs credentials
          ${pkgs.libnotify}/bin/notify-send "VPN" "Credentials required for $VPN_NAME" -u low

          # VPN uses challenge-response 2FA - open terminal for interactive auth
          ${pkgs.libnotify}/bin/notify-send "VPN" "Opening terminal for authentication..." -u low

          ${pkgs.kitty}/bin/kitty --title "VPN Authentication" -e bash -c "
            echo 'Connecting to $VPN_NAME...'
            echo ''
            echo 'This VPN uses challenge-response 2FA.'
            echo 'You will be prompted for username, password, and then a 2FA code.'
            echo ''
            nmcli connection up '$VPN_NAME' --ask
            EXIT_CODE=\$?

            if [ \$EXIT_CODE -eq 0 ]; then
              echo ''
              echo 'Successfully connected to VPN!'
              notify-send 'VPN' 'Connected to $VPN_NAME' -u low
              echo ''
              echo 'Press Enter to close this window...'
              read
            else
              echo ''
              echo 'Failed to connect to VPN.'
              notify-send 'VPN' 'Failed to connect to $VPN_NAME' -u critical
              echo ''
              echo 'Press Enter to close this window...'
              read
            fi
          "
        else
          ${pkgs.libnotify}/bin/notify-send "VPN" "Connected to $VPN_NAME" -u low
        fi
      else
        ${pkgs.libnotify}/bin/notify-send "VPN" "Already connected to $VPN_NAME" -u low
      fi
    fi
  '';

  # Passbolt rofi integration script
  passbolt-rofi = pkgs.writeShellScriptBin "passbolt-rofi" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # List all resources in table format (MUCH faster - no decryption!)
    RESOURCES=$(passbolt list resource --column ID --column Name --column Username 2>&1)

    # Check if there was an error (not configured)
    if echo "$RESOURCES" | grep -q "Error"; then
      ${pkgs.libnotify}/bin/notify-send "🔐 Passbolt" "Not configured. Run: passbolt configure" -u critical
      exit 1
    fi

    if [ -z "$RESOURCES" ]; then
      ${pkgs.libnotify}/bin/notify-send "🔐 Passbolt" "No resources found" -u normal
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
        ${pkgs.libnotify}/bin/notify-send "🔐 Passbolt" "Username copied: $USERNAME" -u low
        ;;
      *"Password"*)
        # Only NOW decrypt the password for the selected resource
        ${pkgs.libnotify}/bin/notify-send "🔐 Passbolt" "Decrypting password..." -u low -t 1000
        PASSWORD=$(passbolt get resource --id "$ID" --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.password')
        echo -n "$PASSWORD" | ${pkgs.wl-clipboard}/bin/wl-copy
        ${pkgs.libnotify}/bin/notify-send "🔐 Passbolt" "Password copied to clipboard" -u low
        ;;
      *"Both"*)
        # Decrypt password for both
        ${pkgs.libnotify}/bin/notify-send "🔐 Passbolt" "Decrypting password..." -u low -t 1000
        PASSWORD=$(passbolt get resource --id "$ID" --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.password')

        # Copy username first
        echo -n "$USERNAME" | ${pkgs.wl-clipboard}/bin/wl-copy
        ${pkgs.libnotify}/bin/notify-send "🔐 Passbolt" "Username copied: $USERNAME\nPassword in 2s..." -u low

        # Wait 2 seconds then copy password
        sleep 2
        echo -n "$PASSWORD" | ${pkgs.wl-clipboard}/bin/wl-copy
        ${pkgs.libnotify}/bin/notify-send "🔐 Passbolt" "Password copied to clipboard" -u low
        ;;
    esac
  '';

in {
  home.packages = with pkgs; [
    rofi
    go-passbolt-cli
    passbolt-rofi
    vpn-rofi
    networkmanager
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
