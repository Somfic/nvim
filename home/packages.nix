{ config, pkgs, inputs, ... }:

{
  programs.ssh = { enable = true; };
  programs.java = { enable = true; };

  home.packages = with pkgs; [
    ffmpeg-full
    vesktop # discord client
    stremio # media streaming app
    vlc
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
    godot # game engine
    sshfs
    sshpass
    filezilla
    ripgrep # fast grep for telescope.nvim
    inputs.neovim-nightly-overlay.packages.${pkgs.system}.default # neovim nightly
    
    # Language servers for neovim
    lua-language-server
    rust-analyzer
    typescript
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted # html, css, json, eslint
    python3Packages.python-lsp-server
    gopls
    clang-tools # clangd for C/C++
    nixd # nix language server
    jdt-language-server # java
    omnisharp-roslyn # .NET/C#
  ];
}
