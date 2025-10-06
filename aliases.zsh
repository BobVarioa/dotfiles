
export PATH=$PATH:/home/bob/apps/portable

alias cl="clear"
alias noansi="sed -e 's/\x1b\[[0-9;]*m//g'"
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias ls="eza --color=always --no-filesize --icons=always --no-time --no-user --no-permissions"
alias l="ls --long"
alias editor="micro"

bottles() {
	flatpak run --command='bottles-cli' com.usebottles.bottles run -b Roblox -e -- "$@"
}


gitlogin() {
	git config user.email "true.email001@gmail.com" && git config user.name "Bob Varioa"
}

pointscsv() {
	cat ./points.json | jq '.[] | [.id, .pointChange, .dateCreated] | @csv' -r > points.csv
}

exportase() {
	~/.steam/steam/steamapps/common/Aseprite/aseprite  -b $1 --save-as {slice}.png 
}


t262() { code ./test262/test262/test/$1 }


proton() {
	PROTON_NO_ESYNC=1 PROTON_DUMP_DEBUG_COMMANDS=1 STEAM_COMPAT_DATA_PATH=~/.wine/ /home/bob/snap/steam/common/.local/share/Steam/steamapps/common/Proton\ 7.0/proton runinprefix "$@"
}

fork() {
	"$@" &!
}

silent() {
	"$@" 2>/dev/null 1>&2 &!
}

wifipasswords() {
	sudo grep psk= /etc/NetworkManager/system-connections/* | sed -E 's/\/etc\/NetworkManager\/system-connections\/(.*)\.nmconnection:psk=(.*)$/\1: \2/'
}

phone() {
	scrcpy -SK --power-off-on-close
}

alias ytdl=yt-dlp
ytdlu() {
	ytdl -j $1 | jq 'include "ytdlu"; main'
}


findpkg() {
	where=$(which $1)
	if [[ "$where" == *"shell built-in command" ]]; then
		echo "shell built-in";
	elif [[ "$where" == *"not found" ]]; then
		echo "not found";
	else
		dpkg -S $where
	fi
}

screenoff() {
	hyprctl dispatch dpms,toggle
}
