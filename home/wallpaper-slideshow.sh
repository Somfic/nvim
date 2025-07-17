#!/usr/bin/env bash

# Wallpaper slideshow script
# Changes wallpaper every 5 minutes

WALLPAPER_DIR="$HOME/dot/wallpapers"
INTERVAL=300  # 5 minutes in seconds

# Initialize swww daemon
swww-daemon &

# Wait a moment for swww to start
sleep 2

# Get all wallpapers
WALLPAPERS=("$WALLPAPER_DIR"/*.{jpg,png,jpeg})

# Remove non-existent files (in case no files match a pattern)
for i in "${!WALLPAPERS[@]}"; do
    if [[ ! -f "${WALLPAPERS[$i]}" ]]; then
        unset 'WALLPAPERS[$i]'
    fi
done

# Rebuild array to remove gaps
WALLPAPERS=("${WALLPAPERS[@]}")

if [[ ${#WALLPAPERS[@]} -eq 0 ]]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

echo "Found ${#WALLPAPERS[@]} wallpapers"
echo "Starting slideshow with ${INTERVAL}s interval..."

# Start the slideshow
counter=0
while true; do
    wallpaper="${WALLPAPERS[$counter]}"
    echo "Setting wallpaper: $(basename "$wallpaper")"
    
    # Set wallpaper with swww
    swww img "$wallpaper" --transition-type wipe --transition-duration 2
    
    # Move to next wallpaper
    counter=$(( (counter + 1) % ${#WALLPAPERS[@]} ))
    
    # Wait for the interval
    sleep "$INTERVAL"
done
