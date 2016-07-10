#!/bin/sh

if [ $# -eq 2 ] && [ "$1" = "red" -o "$1" = "green" -o "$1" = "blue" ] && [ "$2" = "off" -o "$2" = "on" -o "$2" = "flash" -o "$2" = "flash_bg" -o "$2" = "init" ]; then
   num=0
   if [ "$1" = "red" ]; then
      num=33
   elif [ "$1" = "green" ]; then
      num=46
   else
      num=38
   fi

   if [ "$2" != "flash_bg" ]; then
      pkill -f "led.sh $1 flash_bg"
   fi

   if [ "$2" = "off" ]; then
      echo 0 > /sys/class/gpio/gpio${num}/value
   elif [ "$2" = "on" ]; then
      echo 1 > /sys/class/gpio/gpio${num}/value
   elif [ "$2" = "flash" ]; then
      $0 $1 flash_bg &
   elif [ "$2" = "init" ]; then
      echo ${num} > /sys/class/gpio/export
      echo out > /sys/class/gpio/gpio${num}/direction
      echo 0 > /sys/class/gpio/gpio${num}/value
   else      
      while true
      do
         echo 1 > /sys/class/gpio/gpio${num}/value
         sleep 0.5
         echo 0 > /sys/class/gpio/gpio${num}/value
         sleep 0.5
      done
   fi
else
   echo "Usage: led.sh <red|green|blue> <off|on|flash>"
fi

