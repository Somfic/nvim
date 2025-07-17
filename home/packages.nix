{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ffmpeg-full
    vesktop # discord client
    stremio
    google-chrome
    # jetbrains.idea-ultimate
    obs-studio
    mprocs # running multiple processes
    termdown # terminal clock
    just # running commands
    prismlauncher
    swww # wallpaper daemon for wayland
  ];
}
