#!/bin/sh

# When script if started without any arguments, we assume it is called from main.sh
# We restart if with useless param and redirect output to log file on sdcard

if [ $# -eq 0 ]; then
   $0 nop > /sdcard/test/factory_test.log 2>&1 
   exit $?
fi

# Launch telnet server without authentication
telnetd -l /bin/sh &

# Launch ftp server
if [ -f /sdcard/test/v2/bin/tinyftp ]; then
	/sdcard/test/v2/bin/tinyftp -p 21 -c / &
fi

# Setup audio language :
# cn : official, available on camera
# us : unofficial, partially available on camera
# fr : unofficial, available on sdcard
export YIHACKV2_LANGUAGE=fr

# Main hack
rm -f /sdcard/test/yihackv2.log
if [ -f /sdcard/test/v2/bin/yihackv2.so ]; then
	export LD_PRELOAD=/sdcard/test/v2/bin/yihackv2.so
fi

# Duplicate main.sh original commands

/bak/usr/local/bin/gpio_check.sh
value=$?
echo ${value}

if [ ${value} = 2 ]
then
	echo "###Focus Mode###"
	/bak/usr/local/bin/lens_focus.sh
	exit
elif [ ${value} = 3 ]
then
	echo "###Wifi Mode###"
	/bak/usr/local/bin/wifi_mfg.sh
	exit
else
	echo "###Normal Boot###"
fi

######## get config ######
mkdir -p /mnt/cfg
#/usr/sbin/ubiattach /dev/ubi_ctrl -m 8
#mount -t ubifs ubi2_1 /mnt/cfg
mount -t  jffs2  /dev/mtdblock8  /mnt/cfg 

######## wifi ########
/bak/usr/local/bin/usb_wifi.sh
value=$?
echo ${value}

if [ ${value} = 1 ]
then
      echo "@@@we do not launch ipc@@@"
      exit
fi
### 2018 by pass
/usr/local/bin/amba_debug -g 51 -d 0x1

######## cryptography engine ########
modprobe ambarella_crypto config_polling_mode=1
modprobe ambac

######## ipc #########
modprobe pwm_bl

modprobe mn34220pl bus_addr=0x36
/usr/local/bin/init.sh --na

#miio
/usr/local/bin/mosquitto -c /etc/mosquitto.conf -d


#real init ipc
/home/web/show_stack &
/home/web/ipc -w 2>&1 | /home/web/logrunner ipc.log &
