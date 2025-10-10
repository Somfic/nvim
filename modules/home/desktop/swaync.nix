{ config, pkgs, ... }:

{
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      cssPriority = "application";
      control-center-margin-top = 8;
      control-center-margin-bottom = 8;
      control-center-margin-right = 8;
      control-center-margin-left = 8;
      notification-2fa-action = true;
      notification-inline-replies = false;
      notification-icon-size = 64;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      timeout = 10;
      timeout-low = 5;
      timeout-critical = 0;
      fit-to-screen = true;
      control-center-width = 500;
      control-center-height = 600;
      notification-window-width = 500;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      script-fail-notify = true;
      scripts = {};
      notification-visibility = {
        example-name = {
          state = "muted";
          urgency = "Low";
          app-name = "Spotify";
        };
      };
      widgets = [
        "inhibitors"
        "title"
        "dnd"
        "notifications"
      ];
      widget-config = {
        inhibitors = {
          text = "Inhibitors";
          button-text = "Clear All";
          clear-all-button = true;
        };
        title = {
          text = "Notifications";
          clear-all-button = true;
          button-text = "Clear All";
        };
        dnd = {
          text = "Do Not Disturb";
        };
        label = {
          max-lines = 5;
          text = "Label Text";
        };
        mpris = {
          image-size = 96;
          image-radius = 12;
        };
      };
    };
    style = ''
      .floating-notifications.background .notification-row .notification-background {
        box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.15);
        border-radius: 12.6px;
        margin: 18px;
        background-color: rgba(255, 255, 255, 0.8);
        color: rgba(0, 0, 0, 0.88);
        padding: 0;
      }

      .floating-notifications.background .notification-row .notification-background .notification {
        padding: 7px;
        border-radius: 12.6px;
      }

      .floating-notifications.background .notification-row .notification-background .notification.critical {
        box-shadow: inset 0 0 7px 0 rgba(255, 0, 50, 0.15), 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.15);
      }

      .floating-notifications.background .notification-row .notification-background .notification .notification-content {
        background: transparent;
        padding: 7px;
        border-radius: 12.6px;
      }

      .floating-notifications.background .notification-row .notification-background .notification .notification-content .summary {
        font-size: 16px;
        font-weight: 800;
        background: transparent;
        color: rgba(0, 0, 0, 0.88);
        text-shadow: none;
      }

      .floating-notifications.background .notification-row .notification-background .notification .notification-content .time {
        font-size: 16px;
        font-weight: 700;
        background: transparent;
        color: rgba(0, 0, 0, 0.88);
        text-shadow: none;
        margin-right: 18px;
      }

      .floating-notifications.background .notification-row .notification-background .notification .notification-content .body {
        font-size: 15px;
        font-weight: 400;
        background: transparent;
        color: rgba(0, 0, 0, 0.88);
        text-shadow: none;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * {
        min-height: 3.4em;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action {
        border-radius: 7px;
        color: rgba(0, 0, 0, 0.88);
        background-color: rgba(255, 255, 255, 0.7);
        box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.15);
        margin: 7px;
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
        box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.25);
        background-color: rgba(255, 255, 255, 0.9);
      }

      .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
        box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.35);
        background-color: rgba(255, 255, 255, 1);
      }

      .floating-notifications.background .notification-row .notification-background .close-button {
        margin: 18px;
        border-radius: 6.3px;
        color: rgba(0, 0, 0, 0.88);
        text-shadow: none;
        background: rgba(255, 255, 255, 0.7);
        box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.15);
        border: none;
        text-decoration: none;
        font-size: 16px;
        font-weight: 800;
        width: 24px;
        height: 24px;
      }

      .floating-notifications.background .notification-row .notification-background .close-button:hover {
        background: rgba(255, 255, 255, 0.9);
        box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.25);
      }

      .floating-notifications.background .notification-row .notification-background .close-button:active {
        background: rgba(255, 255, 255, 1);
        box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.35);
      }

      .control-center {
        box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.15);
        border-radius: 12.6px;
        margin: 18px;
        background-color: rgba(255, 255, 255, 0.8);
        color: rgba(0, 0, 0, 0.88);
        padding: 14px;
      }

      .control-center .widget-title > label {
        color: rgba(0, 0, 0, 0.88);
        font-size: 1.3em;
      }

      .control-center .widget-title button {
        border-radius: 7px;
        color: rgba(0, 0, 0, 0.88);
        text-shadow: none;
        background: rgba(255, 255, 255, 0.7);
        box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.15);
        border: none;
        text-decoration: none;
      }

      .control-center .widget-title button:hover {
        background: rgba(255, 255, 255, 0.9);
        box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.25);
      }

      .control-center .widget-title button:active {
        background: rgba(255, 255, 255, 1);
        box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.35);
      }
    '';
  };
}