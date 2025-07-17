{ config, pkgs, inputs, lib, ... }:

{
  imports =
    [ ./hardware-configuration.nix inputs.home-manager.nixosModules.default ];

  # system packages
  environment.systemPackages = with pkgs; [
    wget
    curl
    nixfmt
    nix-output-monitor
    os-prober
    git
  ];

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  # user accounts
  users.users.lucas = {
    isNormalUser = true;
    description = "lucas";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ ];
    shell = pkgs.nushell;
  };

  # homemanager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.lucas = import ./home.nix;
    backupFileExtension = "backup";
    sharedModules = [
      inputs.spicetify-nix.homeManagerModules.spicetify
      { 
        stylix.autoEnable = true;
        stylix.targets.spicetify.enable = false;
        stylix.targets.vscode.enable = false;
      }
    ];
  };

  # bootloader
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # docker
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true;

  # hostname  
  networking.hostName = "nixos";

  # xdg.portal.enable = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  programs = {
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages."${pkgs.system}".hyprland;
      # withUWSM = true;
      xwayland.enable = true;
    };
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    gamemode = { enable = true; };
    # spicetify = {
    #   enable = true;
    #   theme = {
    #     name = "hazy";
    #   };
    # };
  };

  # networking 
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.networkmanager.enable = true;

  # locale
  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  # desktop environment
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.displayManager.gdm.enable = true;
  services.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  # services.xserver.libinput.enable = true; # mouse and touchpad support (enabled by default in most desktopManager)

  # printing
  services.printing.enable = true;

  # sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    extraLv2Packages = [ pkgs.rnnoise-plugin ];
    configPackages = [
      (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/20-rnnoise.conf" ''
        context.modules = [
        {   name = libpipewire-module-filter-chain
            args = {
                node.description = "Noise Canceling source"
                media.name = "Noise Canceling source"
                filter.graph = {
                    nodes = [
                        {
                            type = lv2
                            name = rnnoise
                            plugin = "https://github.com/werman/noise-suppression-for-voice#stereo"
                            label = noise_suppressor_stereo
                            control = {
                            }
                        }
                    ]
                }
                capture.props = {
                    node.name =  "capture.rnnoise_source"
                    node.passive = true
                }
                playback.props = {
                    node.name =  "rnnoise_source"
                    media.class = Audio/Source
                }
            }
        }
        ]
      '')
    ];
  };

  # general nixos settings
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";

  hardware = {
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      open = false;
    };
    opengl = {
      enable = true;
      driSupport32Bit = true;
    };
  };
  stylix = {
    enable = true;
    image = ./wallpapers/neon1.jpg;
    polarity = "dark";
    opacity = {
      applications = 0.9;
      desktop = 0.5;
      terminal = 0.9;
      popups = 0.9;
    };
    autoEnable = true;
    targets.spicetify.enable = false;
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 18;
    };
    fonts = {
      monospace = {
        package = pkgs.monocraft;
        name = "Monocraft";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
    };
  };
}
