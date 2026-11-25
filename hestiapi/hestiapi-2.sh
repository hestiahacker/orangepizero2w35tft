#!/bin/bash
script_dir=$(CDPATH= cd -P "$(dirname "$0")" && pwd) || exit 1

# Optional test of the LCD screen itself
#git clone https://github.com/hestiahacker/fbg.git
#cd fbg/examples/
#apt install -y make build-essential
#make earth
#./earth 
#cd -

# Ensure we have a stable device name for the LCD screen
cp $script_dir/99-framebuffer-lcd.rules /etc/udev/rules.d/
udevadm control --reload-rules
udevadm trigger --subsystem-match=graphics

# Configure X to start as a systemd service on boot
cp $script_dir/20-kiosk.conf /etc/X11/xorg.conf.d/
cp $script_dir/xinitrc ~pi/.xinitrc
chown pi:pi ~pi/.xinitrc 
cp $script_dir/set-kiosk-framebuffer /usr/local/sbin/set-kiosk-framebuffer
cp $script_dir/kiosk.service /etc/systemd/system/
systemctl daemon-reload
systemctl disable getty@tty1
# The next command will hijack the local keyboard. Make sure you have
# SSH access set up before you run this.
systemctl enable kiosk.service

# After a reboot, we should see a web browser on the LCD screen
# and the touch screen should work

# Verify the bme280 sensor is working
apt install -y i2c-tools python3-smbus
if [ ! -d hestia-touch-openhab ]; then
	git clone https://github.com/hestiahacker/hestia-touch-openhab.git
fi
cd hestia-touch-openhab/
git checkout ONE-bookworm
python3 home/pi/scripts/bme280.py
cd ..

# Install OpenHAB
mkdir -p /usr/share/keyrings
curl -fsSL "https://openhab.jfrog.io/artifactory/api/gpg/key/public" | gpg --dearmor > /usr/share/keyrings/openhab.gpg
chmod 644 /usr/share/keyrings/openhab.gpg
echo 'deb [signed-by=/usr/share/keyrings/openhab.gpg] https://openhab.jfrog.io/artifactory/openhab-linuxpkg stable main' > /etc/apt/sources.list.d/openhab.list
apt update
apt install -y openjdk-21-jre-headless openhab

# Install other software used by our configuration of OpenHAB
apt install -y mosquitto mosquitto-clients python3 python3-smbus i2c-tools zip unzip curl wget iputils-ping sudo

# And finally, dependencies of our local UI shown on the LCD
apt install -y xinit xserver-xorg xserver-xorg-video-fbdev x11-xserver-utils matchbox-window-manager unclutter xwit fbset chromium net-tools wireless-tools lsb-release bc

# Configure OpenHAB
cd hestia-touch-openhab
python3 tools/build_v5.py --gpio-board orangepi-zero2w
echo "y" | openhab-cli restore v5/hestia-openhab-v5.zip
unzip -oq v5/hestia-openhab-v5.zip -d /tmp/hestia 'home/*' 'setup/*'
/tmp/hestia/setup/install.sh
systemctl enable openhab
cd ..

# Set up turnkey so people can set up their wifi
if [ ! -d raspberry-pi-turnkey ]; then
	git clone https://github.com/hestiahacker/raspberry-pi-turnkey.git
fi
cd raspberry-pi-turnkey
./setup-turnkey.sh wlan0 --no-ap-scan
cd ..

# We're all done. Reboot to see everything come up automatically
shutdown -r now
