#!/bin/bash
# smooth_cursor_zoom.sh
# Parameters: $1 = "in" or "out"

step=0.01      # Base step amount for zoom adjustment
base_delay=0.00002  # Base delay between steps (in seconds)
steps=60       # Increased number of steps for smoother animation
min_zoom=1.0   # Minimum zoom factor
max_zoom=10.0  # Maximum zoom factor

# Get the current zoom factor
current_zoom=$(hyprctl getoption cursor:zoom_factor | grep float | awk '{print $2}')

# Dynamic delay calculation based on zoom level for finer control at higher zoom
function calculate_delay {
    local zoom_level=$1
    echo "$(echo "scale=5; $base_delay + ($zoom_level / $max_zoom * $base_delay)" | bc -l)"
}

if [ "$1" = "in" ]; then
    for i in $(seq 1 $steps); do
        # Increase zoom factor
        new_zoom=$(echo "$current_zoom + ($step * $i)" | bc -l)

        # Clamp to max_zoom
        if (( $(echo "$new_zoom > $max_zoom" | bc -l) )); then
            new_zoom=$max_zoom
            break  # Stop further zoom-in if max reached
        fi

        hyprctl keyword cursor:zoom_factor "$new_zoom"
        sleep $(calculate_delay "$new_zoom")
    done

elif [ "$1" = "out" ]; then
    for i in $(seq 1 $steps); do
        # Decrease zoom factor
        new_zoom=$(echo "$current_zoom - ($step * $i)" | bc -l)

        # Clamp to min_zoom
        if (( $(echo "$new_zoom < $min_zoom" | bc -l) )); then
            new_zoom=$min_zoom
            break  # Stop further zoom-out if min reached
        fi

        hyprctl keyword cursor:zoom_factor "$new_zoom"
        sleep $(calculate_delay "$new_zoom")
    done
fi
