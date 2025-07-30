{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ffmpeg-full
    vesktop # discord client
    stremio # media streaming app
    google-chrome
    # jetbrains.idea-ultimate
    obs-studio
    mprocs # running multiple processes
    termdown # terminal clock
    just # running commands
    prismlauncher # minecraft 
    swww # wallpaper daemon for wayland
    waybar # status bar for wayland
    pavucontrol # audio control GUI for pulseaudio
    font-awesome # icons for waybar
    playerctl # media player control
    claude-code # ai
    papirus-icon-theme # icons for rofi
  ];
}
