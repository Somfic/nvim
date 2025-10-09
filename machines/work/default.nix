{ config, ... }:

{
  imports = [
    ../../home.nix
    ../../profiles/minimal.nix
    ./monitors.nix
  ];
}