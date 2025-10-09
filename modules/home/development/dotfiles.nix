{ config, pkgs, ... }:

{
  home.file.".envrc" = {
    text = ''
      # auto-detect project type and pick template from your dot flake
      if [ -f Cargo.toml ]; then
        nix develop ~/dot#rust --command nu
      elif [ -f package.json ]; then
        nix develop ~/dot#node --command nu
      fi
    '';
  };

  home.file.".config/nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dot/config/nvim";
  };
}