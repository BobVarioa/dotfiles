STATE=`bluetoothctl show | grep Powered | awk '{print $2}'`
if [ $STATE = 'yes' ]; then    
    bluetoothctl power off    
else
    rfkill unblock bluetooth
    bluetoothctl power on
fi
