
#!/bin/sh

targetW=500
targetH=500
targetX=0
targetY=0
# modelWindow=""

hctl() {
	hyprctl $@ > /dev/null
}

# updatefocus() {
# 	local clients=$(hyprctl clients -j)
# 	local existsDisabledPopup=$(echo $clients | jq -r "[.[] | any(.tags[]; . == \"float-popup-disable-focus\")] | any(.)")
# 	local window=$(echo $clients | jq -r "[.[] | select(any(.tags[]; . == \"float-popup-disable-focus\"))] | .[0] | .address")
# 	# echo $existsFloatPopup
# 	if [[ $existsDisabledPopup == "false" ]]; then
# 		echo removing tag
# 		hctl dispatch "tagwindow -float-popup-disable-focus address:$window"
# 	fi
# }

updatecenterwindow() {
	local windowaddress="$1"

	local clients=$(hyprctl clients -j)
	local isFloatPopup=$(echo $clients | jq -r ".[] | select(.address == \"0x$windowaddress\") | any(.tags[]; . == \"float-popup*\")")
		
	if [[ $isFloatPopup == "false" ]]; then
		local windowX=$(echo $clients | jq -r ".[] | select(.address == \"0x$windowaddress\") | .at[0]")
		local windowY=$(echo $clients | jq -r ".[] | select(.address == \"0x$windowaddress\") | .at[1]")
		local windowW=$(echo $clients | jq -r ".[] | select(.address == \"0x$windowaddress\") | .size[0]")
		local windowH=$(echo $clients | jq -r ".[] | select(.address == \"0x$windowaddress\") | .size[1]")
		
		targetW=$(( $windowW / 2))
		targetH=$(( $windowH / 2))
		targetX=$(( ($windowX + ($windowW / 2))-($targetW / 2) ))
		targetY=$(( ($windowY + ($windowH / 2))-($targetH / 2) ))
		# modelWindow="$windowaddress"

		# echo xy:$targetX x $targetY wh:$targetW x $targetH
	else
		hctl dispatch "resizewindowpixel exact $targetW $targetH, tag:.*float-popup.*"
		hctl dispatch "movewindowpixel exact $targetX $targetY, tag:.*float-popup.*"
		# hctl dispatch "tagwindow +float-popup-disable-focus address:$modelWindow"
	fi
}

handle() {
  a="$@"
  case $1 in
    activewindowv2*) updatecenterwindow ${a#*\>\>} ;;
    # closewindow*) updatefocus ;;
  esac
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
