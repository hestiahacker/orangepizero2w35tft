#!/bin/bash
#
# This will take an SD card image
# 
# To make an SD card image, do something like this:
#   sudo dd if=/dev/sda of=armbian-full.img
#
# Example usage:
#   ./minimize_armbian_image.sh armbian-full.img armbian-small.img
#   xz armbian-small.img
#   du -h armbian-small.img.xz
#   xz -d < armbian-small.img.xz | sudo dd of=/dev/sda status=progress
#
if [ -z "$1" -o -z "$2" ]; then
	echo "Usage: $0 input.img output.img"
	exit 1
fi

# Get the script
if [ ! -f armbianshrink.sh ]; then
	wget -O armbianshrink.sh https://raw.githubusercontent.com/lededev/ArmbianShrink/master/armbianshrink.sh
fi
if [ ! -x armbianshrink.sh ]; then
	chmod +x armbianshrink.sh
fi

# Run the script
sudo ./armbianshrink.sh "$1" "$2"
