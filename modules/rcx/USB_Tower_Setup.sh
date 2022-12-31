parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P ) && cd "$parent_path"

# Create group 'lego' for use with lego devices, then add the specified user to 'lego' so they can use it.
echo 'Setting up USB IR tower.'
read -p 'Enter your username: ' u
sudo groupadd lego
sudo usermod -a -G lego $u

# If it hasn't been done already, set module "legousbtower" to load automatically at startup.
sudo grep -q -F 'legousbtower' /etc/modules || echo 'legousbtower' | sudo tee --append /etc/modules

# If it hasn't been done already, give the 'lego' group permission to use the usb tower.
if [[ ! -e /etc/udev/rules.d/90-legotower.rules ]]; then
    id=`lsusb | grep 'Mindstorms Tower' | grep -oP "ID\s+\K\d{4}:\d{4}"`
    IFS=':' read -r vendor product <<< "$id"
    echo 'ATTRS{idVendor}=="'$vendor'",ATTRS{idProduct}=="'$product'",MODE="0666",GROUP="lego"' | sudo tee --append /etc/udev/rules.d/90-legotower.rules
fi

echo 
echo 'Lego USB IR Tower should now be installed (hopefully).'
echo 'After reboot, use: "ls /dev/usb"  to find your usb tower device.'
read -n 1 -s -r -p 'Rebooting now. Press any key to continue...'
echo 
shutdown -r +1 "Rebooting to load USB Tower drivers."

