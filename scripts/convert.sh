
EXT=".mkv"
for VIDEOPATH in ./**$EXT; do
    VIDEO=${VIDEOPATH%$EXT}
    ffmpeg -i "./$VIDEO$EXT" -vf scale=1280:720 "$VIDEO-converted.mp4";
    mv "$VIDEO-converted.mp4" "../Game Changer/";
    rm "$VIDEO$EXT"
done
