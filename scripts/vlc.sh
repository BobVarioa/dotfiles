alias ytdl=yt-dlp # you could use ytdl if you wanted instead
ytdlu() {
	ytdl -j $1 | jq 'include "ytdlu"; main'
}

url=$(ytdlu $1 | jq -r "last | .url")
if [ "$url" != "null" ]; then
    vlc $url
else
    echo "failed";
fi
