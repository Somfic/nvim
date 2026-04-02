{ config, pkgs, ... }:

{
  users.users.lucas = {
    isNormalUser = true;
    description = "lucas";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ ];
    shell = pkgs.bash;
  };

  users.users.ghost = {
    isNormalUser = true;
    uid = 1001;
    description = "ghost";
    extraGroups = [ "video" "audio" ];
    shell = pkgs.bash;
  };
}
