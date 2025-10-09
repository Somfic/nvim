{ config, ... }:

{
  imports = [ ../../home.nix ../../profiles/desktop-full.nix ./monitors.nix ];
}
