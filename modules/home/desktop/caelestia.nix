{ config, pkgs, ... }:

{
  # Create Caelestia configuration directory and files
  home.file.".config/caelestia/shell.json".text = builtins.toJSON {
    paths = { wallpaperDir = "${config.home.homeDirectory}/dot/wallpapers"; };
    appearance = {
      transparency = { enabled = false; };
      iconTheme = "Papirus-Dark";
    };
    border = {
      rounding = 25;
      thickness = 1;
    };
    launcher = {
      fuzzySearch = true;
      dangerousActions = true;
    };
    general = { apps = { terminal = [ "kitty" ]; }; };
    wallpaper = { current = "${config.home.homeDirectory}/dot/wallpapers/neon1.jpg"; };
    background = {
      enabled = false; # Using swww for wallpaper management instead
    };
    lock = { recolourLogo = true; };
    workspaces = { showWindows = false; };
    bar = {
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
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dot/wallpapers";

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
        $DRY_RUN_CMD echo "${config.home.homeDirectory}/dot/wallpapers/neon1.jpg" > "$WALLPAPER_STATE"
      fi
    '';
}
