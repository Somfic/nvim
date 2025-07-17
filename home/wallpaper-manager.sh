#!/usr/bin/env bash

# Wallpaper slideshow configuration and management script
# This script provides more control over your wallpaper slideshow

WALLPAPER_DIR="$HOME/dot/wallpapers"
CONFIG_FILE="$HOME/.config/wallpaper-slideshow.conf"

# Default configuration
DEFAULT_INTERVAL=300  # 5 minutes
DEFAULT_TRANSITION="fade"
DEFAULT_TRANSITION_DURATION=1

# Create config file if it doesn't exist
if [[ ! -f "$CONFIG_FILE" ]]; then
    cat > "$CONFIG_FILE" << EOF
# Wallpaper slideshow configuration
INTERVAL=$DEFAULT_INTERVAL
TRANSITION=$DEFAULT_TRANSITION
TRANSITION_DURATION=$DEFAULT_TRANSITION_DURATION
SHUFFLE=true
EOF
fi

# Source configuration
source "$CONFIG_FILE"

# Functions
show_help() {
    echo "Wallpaper Slideshow Manager"
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start       Start the slideshow (default)"
    echo "  stop        Stop the slideshow"
    echo "  next        Skip to next wallpaper"
    echo "  prev        Go to previous wallpaper"
    echo "  random      Set random wallpaper"
    echo "  list        List available wallpapers"
    echo "  config      Edit configuration"
    echo "  help        Show this help"
    echo ""
    echo "Configuration file: $CONFIG_FILE"
}

start_slideshow() {
    # Check if already running
    if pgrep -f "wallpaper-manager.sh start" > /dev/null; then
        echo "Slideshow is already running!"
        return 1
    fi

    # Kill any existing swww daemon to avoid conflicts
    pkill swww-daemon 2>/dev/null
    sleep 1

    # Initialize swww daemon
    echo "Starting swww daemon..."
    swww-daemon &
    sleep 3  # Give more time for daemon to start

    # Get all wallpapers
    WALLPAPERS=("$WALLPAPER_DIR"/*.{jpg,png,jpeg})
    
    # Remove non-existent files
    for i in "${!WALLPAPERS[@]}"; do
        if [[ ! -f "${WALLPAPERS[$i]}" ]]; then
            unset 'WALLPAPERS[$i]'
        fi
    done
    
    # Rebuild array
    WALLPAPERS=("${WALLPAPERS[@]}")
    
    if [[ ${#WALLPAPERS[@]} -eq 0 ]]; then
        echo "No wallpapers found in $WALLPAPER_DIR"
        return 1
    fi

    echo "Found ${#WALLPAPERS[@]} wallpapers"
    echo "Starting slideshow with ${INTERVAL}s interval..."
    
    # Shuffle if enabled
    if [[ "$SHUFFLE" == "true" ]]; then
        echo "Shuffling wallpapers..."
        WALLPAPERS=($(printf '%s\n' "${WALLPAPERS[@]}" | shuf))
    fi

    # Start the slideshow
    counter=0
    while true; do
        wallpaper="${WALLPAPERS[$counter]}"
        echo "Setting wallpaper: $(basename "$wallpaper")"
        
        # Use simpler transition to avoid buffer issues
        swww img "$wallpaper" --transition-type fade --transition-duration 1 2>/dev/null || {
            echo "Failed to set wallpaper, retrying without transition..."
            swww img "$wallpaper" 2>/dev/null
        }
        
        counter=$(( (counter + 1) % ${#WALLPAPERS[@]} ))
        
        # Re-shuffle when we complete a cycle
        if [[ $counter -eq 0 ]] && [[ "$SHUFFLE" == "true" ]]; then
            WALLPAPERS=($(printf '%s\n' "${WALLPAPERS[@]}" | shuf))
        fi
        
        sleep "$INTERVAL"
    done
}

stop_slideshow() {
    pkill -f "wallpaper-manager.sh start"
    pkill swww-daemon 2>/dev/null
    echo "Slideshow stopped"
}

next_wallpaper() {
    if ! pgrep swww-daemon > /dev/null; then
        swww-daemon &
        sleep 1
    fi
    
    WALLPAPERS=("$WALLPAPER_DIR"/*.{jpg,png,jpeg})
    for i in "${!WALLPAPERS[@]}"; do
        if [[ ! -f "${WALLPAPERS[$i]}" ]]; then
            unset 'WALLPAPERS[$i]'
        fi
    done
    WALLPAPERS=("${WALLPAPERS[@]}")
    
    if [[ ${#WALLPAPERS[@]} -eq 0 ]]; then
        echo "No wallpapers found"
        return 1
    fi
    
    # Get a random wallpaper
    wallpaper="${WALLPAPERS[$RANDOM % ${#WALLPAPERS[@]}]}"
    echo "Next wallpaper: $(basename "$wallpaper")"
    swww img "$wallpaper" --transition-type fade --transition-duration 1 2>/dev/null || {
        echo "Failed to set wallpaper, retrying without transition..."
        swww img "$wallpaper" 2>/dev/null
    }
}

random_wallpaper() {
    next_wallpaper
}

list_wallpapers() {
    echo "Available wallpapers:"
    for wallpaper in "$WALLPAPER_DIR"/*.{jpg,png,jpeg}; do
        if [[ -f "$wallpaper" ]]; then
            echo "  $(basename "$wallpaper")"
        fi
    done
}

edit_config() {
    ${EDITOR:-nano} "$CONFIG_FILE"
    echo "Configuration updated. Restart slideshow to apply changes."
}

# Main script logic
case "${1:-start}" in
    start)
        start_slideshow
        ;;
    stop)
        stop_slideshow
        ;;
    next)
        next_wallpaper
        ;;
    prev)
        next_wallpaper  # For now, just go to next
        ;;
    random)
        random_wallpaper
        ;;
    list)
        list_wallpapers
        ;;
    config)
        edit_config
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
