/usr/bin/plank 2>/dev/null 1>&2 &
disown $!
/usr/local/bin/autoplank 2>/dev/null 1>&2 &
disown $!
