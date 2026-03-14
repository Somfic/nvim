{ config, pkgs, lib, inputs, ... }:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  programs.spicetify = {
    enable = true;

    # Let stylix handle the theme
    enabledExtensions = with spicePkgs.extensions; [
      adblock
      shuffle
      hidePodcasts
    ];
  };
}
