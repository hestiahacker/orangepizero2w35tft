# Device tree overlay and xorg config files for a 3.5 inch SPI ili9486 display on the Orangepi Zero 2W

I used this display https://joy-it.net/en/products/RB-TFT3.5 - but I think the waveshare 35a has a similar pinout. Take a look at the pinout diagram! </br>
</br>
Steps to make it work:

```
sudo apt install -y git
git clone https://github.com/dev-null2019/orangepizero2w35tft
cd orangepizero2w35tft

sudo apt install -y xorg
sudo mv ./80-calibration.conf /usr/share/X11/xorg.conf.d
sudo mv ./99-fbdev.conf /usr/share/X11/xorg.conf.d

# If on Armbian
cp /etc/armbian-release /etc/orangepi-release
git clone https://github.com/orangepi-xunlong/orangepi-build
cp orangepi-build/external/packages/bsp/common/usr/sbin/orangepi-add-overlay /usr/sbin/

sudo orangepi-add-overlay ./joyit35a-overlay.dts
sudo cp /boot/orangepiEnv.txt /boot/armbianEnv.txt  # only needed on Armbian
echo fbtft | sudo tee /etc/modules-load.d/fbtft.conf

# Blacklist the driver that uses Direct Rendering Manager so it doesn't conflict
echo "blacklist ili8486" | tee /etc/modprobe.d/blacklist-ili9486.conf

reboot

# To test it out
cd ..
git clone https://github.com/hestiahacker/fbg
cd fbg/examples
sudo apt install -y make build-essential
make earth
./earth
```

