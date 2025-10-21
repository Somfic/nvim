{ config, pkgs, ... }:

let
  # Wrapper script that runs nwg-displays and reloads Hyprland config after
  monitorConfigScript = pkgs.writeShellScriptBin "monitor-config" ''
    #!/usr/bin/env bash

    # Store the original monitors.conf checksum
    MONITORS_CONF="$HOME/.config/hypr/monitors.conf"
    BEFORE_CHECKSUM=""

    if [ -f "$MONITORS_CONF" ]; then
      BEFORE_CHECKSUM=$(sha256sum "$MONITORS_CONF" | cut -d' ' -f1)
    fi

    # Run nwg-displays
    ${pkgs.nwg-displays}/bin/nwg-displays

    # Check if monitors.conf was modified
    AFTER_CHECKSUM=""
    if [ -f "$MONITORS_CONF" ]; then
      AFTER_CHECKSUM=$(sha256sum "$MONITORS_CONF" | cut -d' ' -f1)
    fi

    # If it changed, reload Hyprland config
    if [ "$BEFORE_CHECKSUM" != "$AFTER_CHECKSUM" ]; then
      echo "Monitors configuration changed, reloading Hyprland..."
      hyprctl reload
    fi
  '';
in
{
  # nwg-displays: GUI monitor configuration tool for Hyprland
  # Plus our wrapper script that auto-reloads Hyprland
  home.packages = with pkgs; [
    nwg-displays
    monitorConfigScript
  ];

  # Desktop entry for Caelestia launcher
  xdg.desktopEntries.monitor-config = {
    name = "Monitor Configuration";
    genericName = "Display Settings";
    comment = "Configure monitor layout and settings";
    exec = "monitor-config";
    icon = "video-display";
    categories = [ "Settings" "HardwareSettings" ];
    terminal = false;
  };

  # Note: monitors.conf is managed by nwg-displays, not by home-manager
  # Launch with: monitor-config (auto-reloads) or nwg-displays (manual reload)
  # Keybind: Super+O
}
