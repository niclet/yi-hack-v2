#!/bin/sh

echo "### ORIGINAL startup ... ###"

/bak/usr/local/bin/gpio_check.sh

# Wifi
/bak/usr/local/bin/usb_wifi.sh

# 2018 by pass
/usr/local/bin/amba_debug -g 51 -d 0x1

# Cryptography engine
modprobe ambarella_crypto config_polling_mode=1
modprobe ambac

# ipc
modprobe pwm_bl

modprobe mn34220pl bus_addr=0x36
/usr/local/bin/init.sh --na

#miio
/usr/local/bin/mosquitto -c /etc/mosquitto.conf -d

#real init ipc
/home/web/show_stack &

/home/web/ipc -w &
