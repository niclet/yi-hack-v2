#!/bin/sh

echo "### MODIFIED startup ... ###"

# Copy wpa_supplicant.conf
if [ -f /sdcard/test/wpa_supplicant.conf ]; then
   mkdir -p /tmp/config
   cp -f /sdcard/test/wpa_supplicant.conf /tmp/config/wpa_supplicant.conf
else
   echo "Error: /sdcard/test/wpa_supplicant.conf is not available"
   exit
fi

# Wifi

# USB 2.0 'Enhanced' Host Controller (EHCI) Driver
modprobe ehci-hcd
# Ambarella USB Device Controller Gadget
modprobe ambarella_udc
# Mass Storage Gadget
modprobe g_mass_storage file=/dev/mmcblk0p1 stall=0 removable=1

echo device > /proc/ambarella/usbphy0

sleep 1s
/usr/local/bin/amba_debug -g 26 -d 0x1
sleep 2s

echo host > /proc/ambarella/usbphy0

# M-WLAN MLAN Driver
modprobe mlan
# M-WLAN Driver
modprobe usb8801
sleep 2
ifconfig mlan0 up

# Set wifi wmm
/lib/firmware/mrvl/mlanutl mlan0 wmmparamcfg 0 2 3 2 150  1 2 3 2 150  2 2 3 2 150  3 2 3 2 150
/lib/firmware/mrvl/mlanutl mlan0 macctrl 0x13
/lib/firmware/mrvl/mlanutl mlan0 psmode 0

# Set wifi countrycode
/lib/firmware/mrvl/mlanutl mlan0 countrycode CN

wifi_auto.sh

# MN34220PL 1/3 -Inch, 1944x1213, 2.4-Megapixel CMOS Digital Image Sensor
modprobe mn34220pl bus_addr=0x36

/usr/local/bin/init.sh --na

/usr/local/bin/test_tuning -a 0 &
/usr/local/bin/test_encode -A -i 1920x1080 --bitrate 1200000 -f 25 --enc-mode 4 --hdr-expo 2 --hdr-mode 1 -J --btype off  -K --btype off -X --bmaxsize 1920x1080 --bsize 1920x1080 --smaxsize 1920x1080 -Y --bmaxsize 640x360 --bsize 640x360 -B -m 640x360 --smaxsize 640x360
/usr/local/bin/rtsp_server &
/usr/local/bin/test_encode -A -h 1080p -e --bitrate 1200000
