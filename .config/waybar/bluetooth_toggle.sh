STATE=`bluetoothctl show | grep Powered | awk '{print $2}'`
if [ $STATE = 'yes' ]; then    
    bluetoothctl power off    
    notify-send "Bluetooth Off"
else
    rfkill unblock bluetooth
    bluetoothctl power on
    notify-send "Bluetooth On"
fi
