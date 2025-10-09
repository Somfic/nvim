{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ffmpeg-full
    vlc
    obs-studio
    swww # wallpaper daemon for wayland
    pavucontrol # audio control GUI for pulseaudio
    playerctl # media player control
    prismlauncher # minecraft
    # stremio # media streaming app
  ];
}