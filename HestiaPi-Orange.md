These are instructions for getting an Orange Pi Zero 2 W set up with an LCD
screen, a BME280 temperature/humidity sensor, and relays to function as an
open source smart thermostat. It's based on the work of the [HestiaPi
project](https://HestiaPi.com).

1. Download the [Armbian image](https://armbian.com/boards/orangepizero2w)
   and flash it to an SD card
2. Boot it, going through Armbian's initial setup wizard (including WiFi)
3. Download all the files [here](hestiapi) to your Armbian machine
4. Run hestiapi-1.sh, which will reboot when it's done
5. Run hestiapi-2.sh, which will reboot when it's done

At that point, you should have a fully functional thermostat (assuming you have
the LCD touchscreen, temperature sensor and relays connected)!
