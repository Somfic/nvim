{ config, pkgs, ... }:

{
  # Create Caelestia configuration directory and files
  home.file.".config/caelestia/shell.json".text = builtins.toJSON {
    paths = { wallpaperDir = "/home/lucas/dot/wallpapers"; };
    launcher = {
      maxWallpapers = 9;
      maxShownActions = 8;
      maxShownApplications = 8;
      fuzzySearch = true;
      dangerousActions = true;
      vimKeybinds = false;
    };
    wallpaper = { current = "/home/lucas/dot/wallpapers/neon1.jpg"; };
  };

  # Create symlink to wallpapers in the default Pictures directory for convenience
  home.file."Pictures/Wallpapers".source =
    config.lib.file.mkOutOfStoreSymlink "/home/lucas/dot/wallpapers";

  # Create Caelestia wallpaper state file
  home.file.".local/state/caelestia/wallpaper/path.txt".text =
    "/home/lucas/dot/wallpapers/neon1.jpg";

  # Create Caelestia color scheme file for Stylix integration
  home.file.".local/state/caelestia/scheme.json".text = builtins.toJSON {
    base00 = config.lib.stylix.colors.base00 or "#1e1e2e"; # base
    base01 = config.lib.stylix.colors.base01 or "#181825"; # mantle
    base02 = config.lib.stylix.colors.base02 or "#313244"; # surface0
    base03 = config.lib.stylix.colors.base03 or "#45475a"; # surface1
    base04 = config.lib.stylix.colors.base04 or "#585b70"; # surface2
    base05 = config.lib.stylix.colors.base05 or "#cdd6f4"; # text
    base06 = config.lib.stylix.colors.base06 or "#f5e0dc"; # rosewater
    base07 = config.lib.stylix.colors.base07 or "#b4befe"; # lavender
    base08 = config.lib.stylix.colors.base08 or "#f38ba8"; # red
    base09 = config.lib.stylix.colors.base09 or "#fab387"; # peach
    base0A = config.lib.stylix.colors.base0A or "#f9e2af"; # yellow
    base0B = config.lib.stylix.colors.base0B or "#a6e3a1"; # green
    base0C = config.lib.stylix.colors.base0C or "#94e2d5"; # teal
    base0D = config.lib.stylix.colors.base0D or "#89b4fa"; # blue
    base0E = config.lib.stylix.colors.base0E or "#cba6f7"; # mauve
    base0F = config.lib.stylix.colors.base0F or "#f2cdcd"; # flamingo
  };
}
