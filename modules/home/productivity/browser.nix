{ config, pkgs, lib, ... }:

{
  # Default browser is Brave, but can be overridden per-machine
  programs.brave.enable = lib.mkDefault true;
  programs.firefox.enable = lib.mkDefault false;
  programs.google-chrome.enable = lib.mkDefault false;

  programs.firefox.profiles.default = {
    settings = {
      # Allow transparent windows on Wayland
      "widget.wayland.opaque-region.enabled" = false;
      # Required for userChrome.css
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      # Allow web content to be truly transparent to compositor (Firefox 128+)
      "browser.tabs.allow_transparent_browser" = true;
      "browser.display.background_color.dark" = "#00000000";
    };
    userChrome = ''
      /* Make Firefox chrome transparent */
      :root {
        --lwt-accent-color: transparent !important;
        --lwt-toolbarbutton-background: transparent !important;
        --toolbar-bgcolor: transparent !important;
        --lwt-toolbar-body-bg: transparent !important;
        --tabpanel-background-color: transparent !important;
      }
      #navigator-toolbox, #main-window, #browser,
      #appcontent, #tabbrowser-tabpanels {
        background: transparent !important;
        background-color: transparent !important;
      }
      /* Tab bar */
      #titlebar, #TabsToolbar {
        background: transparent !important;
      }
      /* Navigation bar */
      #nav-bar {
        background: transparent !important;
      }
      /* Sidebar */
      #sidebar-box {
        background: transparent !important;
      }
    '';
    userContent = ''
      /* Make all pages' canvas transparent so sites with transparent bg show wallpaper */
      @-moz-document regexp(".*") {
        html {
          background-color: transparent !important;
        }
      }
      /* YouTube */
      @-moz-document domain("youtube.com") {
        ytd-app {
          background: transparent !important;
        }
      }
      /* Google */
      @-moz-document domain("google.com") {
        body {
          background: transparent !important;
        }
      }
      /* Gmail — make theme background image transparent so wallpaper shows */
      @-moz-document domain("mail.google.com") {
        body, body .wl {
          background-image: none !important;
          background-color: transparent !important;
          background: transparent !important;
        }
      }
      /* GitLab */
      @-moz-document domain("gitlab.com") {
        body, html.gl-dark, html.gl-light {
          background-color: transparent !important;
        }
        .navbar-gitlab, header.navbar-gitlab {
          background-color: transparent !important;
        }
        :root {
          --super-sidebar-bg: transparent !important;
        }
        .content-wrapper, .layout-page {
          background-color: transparent !important;
        }
        .row-content-block, .sub-header-block, .detail-page-header {
          background-color: transparent !important;
        }
        .card, .card .card-header {
          background-color: transparent !important;
        }
      }
    '';
  };
}
