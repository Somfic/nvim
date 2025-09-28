{ config, pkgs, ... }:

{
  # Create Caelestia configuration directory and files
  home.file.".config/caelestia/shell.json".text = builtins.toJSON {
    paths = {
      wallpaperDir = "/home/lucas/dot/wallpapers";
    };
    launcher = {
      maxWallpapers = 9;
    };
  };

  # Create symlink to wallpapers in the default Pictures directory for convenience
  home.file."Pictures/Wallpapers".source = config.lib.file.mkOutOfStoreSymlink "/home/lucas/dot/wallpapers";
}