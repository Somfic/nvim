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
    };
    userChrome = ''
      /* Transparent Firefox UI */
      :root {
        --toolbar-bgcolor: transparent !important;
        --lwt-accent-color: transparent !important;
        --lwt-toolbarbutton-hover-background: rgba(255,255,255,0.1) !important;
      }
      #navigator-toolbox, #toolbar-menubar, #TabsToolbar,
      #PersonalToolbar, #nav-bar, #urlbar-background {
        background: transparent !important;
        background-color: transparent !important;
      }
      #main-window, #browser, #appcontent {
        background: transparent !important;
      }
      #sidebar-box, #sidebar-header {
        background: transparent !important;
      }
    '';
    userContent = ''
      /* Transparent page backgrounds for blur effect */
      @-moz-document url-prefix("about:") {
        html, body {
          background: transparent !important;
        }
      }
    '';
  };
}
