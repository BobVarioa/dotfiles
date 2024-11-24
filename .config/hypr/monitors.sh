#!/bin/sh

hyprctl monitors -j | jq -r ".[].name" | while read line; do
  glpaper $line ~/.config/hypr/sky.frag --fps 5 -F;
done

handle() {
  a="$@"
  case $1 in
    monitoradded\>\>*) glpaper ${a#*\>\>} ~/.config/hypr/sky.frag --fps 5 -F ;;
    monitorremoved\>\>*) pkill -f "glpaper ${a#*\>\>}" ;;
  esac
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
