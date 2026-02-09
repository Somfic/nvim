{ config, pkgs, ... }:

{
  users.users.lucas = {
    isNormalUser = true;
    description = "lucas";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ ];
    shell = pkgs.bash;
  };
}
