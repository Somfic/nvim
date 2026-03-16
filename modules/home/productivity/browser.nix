{ config, pkgs, lib, ... }:

{
  # Default browser is Brave, but can be overridden per-machine
  programs.brave.enable = lib.mkDefault true;
  programs.firefox.enable = lib.mkDefault false;
  programs.google-chrome.enable = lib.mkDefault false;

  # Firefox transparency via home-manager managed profile
  programs.firefox.profiles.default = {
    settings = {
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      "layout.css.moz-document.content.enabled" = true;
      "widget.wayland.opaque-region.enabled" = false;
      "browser.display.background_color" = "#00000000";
      "browser.display.background_color.dark" = "#00000000";
      "browser.display.use_system_colors" = false;
    };
    userChrome = ''
      /* Force ALL browser chrome to transparent — catches GTK-themed containers */
      *, *::before, *::after {
        background-color: transparent !important;
        background-image: none !important;
      }

      /* Re-apply specific styles for interactive elements */
      :root {
        --toolbar-bgcolor: transparent !important;
        --lwt-accent-color: transparent !important;
        --lwt-toolbarbutton-hover-background: rgba(255,255,255,0.1) !important;
      }
      #urlbar-background {
        background-color: transparent !important;
      }
      #urlbar[focused] #urlbar-background {
        background-color: rgba(0,0,0,0.3) !important;
      }
    '';
    userContent = ''
      /* Transparent page backgrounds for blur effect */
      @-moz-document url-prefix("about:") {
        html, body {
          background: transparent !important;
        }
      }

      @-moz-document domain("google.com") {
        html, body {
          background: transparent !important;
        }
      }

      @-moz-document domain("localhost") {
        html, body {
          background: transparent !important;
        }
      }

      @-moz-document domain("127.0.0.1") {
        html, body {
          background: transparent !important;
        }
      }

      @-moz-document domain("youtube.com") {
        html, body, ytd-app {
          background: transparent !important;
        }
      }
    '';
  };
}
