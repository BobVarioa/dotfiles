silent tilix
# wmctrl -ia $(wmctrl -l | tail -1 | sed -e 's/^\([^ ]*\).*$/\1/')