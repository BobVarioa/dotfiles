sleep 3;
if [[ $(xrandr --listactivemonitors | tail --lines 2 | wc -l) -gt 1 ]]
then
    plank -n 2;
else
    plank;
fi
