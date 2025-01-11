pkill -9 waybar
hyprctl clients -j | jq ".[]|.address" | xargs -I {} hyprctl dispatch -- tagwindow +gone address:{}
hyprctl keyword group:groupbar:enabled false
swaync-client -Ia locked
hyprlock
waybar &
hyprctl clients -j | jq ".[]|.address" | xargs -I {} hyprctl dispatch -- tagwindow -gone address:{}
hyprctl keyword group:groupbar:enabled true
swaync-client -Ir locked