{ config, pkgs, ... }:

{
  # Create Caelestia configuration directory and files
  home.file.".config/caelestia/shell.json".text = builtins.toJSON {
    paths = { wallpaperDir = "/home/lucas/dot/wallpapers"; };
    appearance = {
      transparency = { enabled = false; };
      iconTheme = "Papirus-Dark";
    };
    border = {
      rounding = 25;
      thickness = 8;
    };
    launcher = {
      fuzzySearch = true;
      dangerousActions = true;
    };
    general = { apps = { terminal = [ "kitty" ]; }; };
    wallpaper = { current = "/home/lucas/dot/wallpapers/neon1.jpg"; };
    background = {
      desktopClock.enabled = false;
      visualiser.enabled =
        false; # Disabled to prevent QString assignment errors
    };
    lock = { recolourLogo = true; };
    bar = {
      clock = { showIcon = false; };
      workspaces = { showWindows = false; };
      status = {
        showMicrophone = true;
        showKbLayout = false;
      };
      tray = {
        enabled = false;
        recolour = true;
      };
    };
    utilities = {
      toasts = {
        audioInputChanged = true;
        audioOutputChanged = true;
        capsLockChanged = false;
        chargingChanged = true;
        configLoaded = true;
        dndChanged = true;
        gameModeChanged = true;
        numLockChanged = false;
      };
    };
  };

  # Create symlink to wallpapers in the default Pictures directory for convenience
  home.file."Pictures/Wallpapers".source =
    config.lib.file.mkOutOfStoreSymlink "/home/lucas/dot/wallpapers";

  # Note: Caelestia manages its own state files in ~/.local/state/caelestia/
  # These files need to be writable by Caelestia, so we don't create them here.
  # Caelestia will create:
  # - ~/.local/state/caelestia/wallpaper/path.txt (current wallpaper)
  # - ~/.local/state/caelestia/scheme.json (generated color scheme)

  # Initialize wallpaper state if missing
  home.activation.initCaelestiaWallpaper =
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      WALLPAPER_STATE="$HOME/.local/state/caelestia/wallpaper/path.txt"
      if [ ! -f "$WALLPAPER_STATE" ]; then
        $DRY_RUN_CMD mkdir -p "$(dirname "$WALLPAPER_STATE")"
        $DRY_RUN_CMD echo "/home/lucas/dot/wallpapers/neon1.jpg" > "$WALLPAPER_STATE"
      fi
    '';
}
