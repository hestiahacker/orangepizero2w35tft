#!/bin/bash
apt update
apt install -y vim git xorg chromium

# Get the scipt needed to install an overlay file
if [ ! -d orangepi-build ]; then
	git clone https://github.com/orangepi-xunlong/orangepi-build
fi
cp orangepi-build/external/packages/bsp/common/usr/sbin/orangepi-add-overlay /usr/sbin/
# Make Armbian look like what the orangepi-script expects
cp /etc/armbian-release /etc/orangepi-release
cp /boot/armbianEnv.txt /boot/orangepiEnv.txt

# Add overlay and load the framebuffer driver, not the DRM one
if [ ! -d orangepizero2w35tft/ ]; then
	git clone https://github.com/hestiahacker/orangepizero2w35tft.git
fi
cd orangepizero2w35tft/
orangepi-add-overlay ./joyit35a-overlay.dts 
cp /boot/orangepiEnv.txt /boot/armbianEnv.txt 
echo fbtft > /etc/modules-load.d/fbtft.conf
echo "blacklist ili9486" > /etc/modprobe.d/blacklist-ili9486.conf
# Set up the touch input for being in landscape mode
cp 80-calibration.conf /etc/X11/xorg.conf.d/
cd ..

echo "Rebooting to apply hardware changes (overlay file)..."
sleep 5
shutdown -r now
