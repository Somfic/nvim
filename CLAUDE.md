# Configuration Structure

## Machine Switching

Switch between machines using:
```bash
# For home machine
nixos-rebuild switch --flake .#home
home-manager switch --flake .#home

# For work machine
nixos-rebuild switch --flake .#work
home-manager switch --flake .#work
```

## Directory Structure

```
├── machines/           # Machine-specific configurations
│   ├── home/          # Home machine (hardware.nix, monitors.nix, default.nix)
│   └── work/          # Work machine (hardware.nix, monitors.nix, default.nix)
├── modules/
│   ├── home/          # Home-manager modules by category
│   │   ├── desktop/   # Desktop environment (hyprland, caelestia, launcher)
│   │   ├── shell/     # Shell and terminal (nushell, tools)
│   │   ├── development/ # Dev tools (core, editors, dotfiles)
│   │   ├── media/     # Media and entertainment (packages, spicetify)
│   │   └── productivity/ # Communication and office (browser, communication, tools)
│   └── system/        # NixOS system modules
└── profiles/          # Pre-configured module combinations
    ├── desktop-full.nix # Full desktop environment
    └── minimal.nix    # Minimal setup for servers/work
```

## Adding New Modules

1. Create module in appropriate `modules/home/` category
2. Add to relevant profile in `profiles/`
3. Machine-specific configs go in `machines/{machine}/`

## Testing Changes

Always run before switching:
```bash
nix flake check
```