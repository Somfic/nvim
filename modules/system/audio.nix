{ config, pkgs, ... }:

{
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
}
