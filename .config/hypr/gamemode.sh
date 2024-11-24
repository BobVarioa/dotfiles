#!/usr/bin/env sh
HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
if [ "$HYPRGAMEMODE" = 1 ] ; then
    hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:drop_shadow 0;\
        keyword decoration:blur:enabled 0;\
        keyword decoration:rounding 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 0;\
        keyword input:follow_mouse 0;\
        dispatch fullscreenstate -1 2"
    pkill -9 waybar
    exit
fi
hyprctl reload
hyprctl dispatch fullscreenstate -1 2
waybar &
