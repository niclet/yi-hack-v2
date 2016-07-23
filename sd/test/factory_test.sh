#!/bin/sh

# When script if started without any arguments, we assume it is called from main.sh
# We restart if with useless param and redirect output to log file on sdcard

if [ $# -eq 0 ]; then
   export YI_HACK_LOGS=/sdcard/test/logs
   mkdir -p "$YI_HACK_LOGS"
   $0 nop > "$YI_HACK_LOGS/factory_test.log" 2>&1
   exit $?
fi

# Export all variables available in yi-hack-v2.cfg
if [ -f /sdcard/test/yi-hack-v2.cfg ]; then
   echo "### Export variables ... ###"
   while read assignment; do
      if [ "${assignment:0:8}" = "YI_HACK_" ]; then
         echo -e "export \"$assignment\""
         export "$assignment"
      fi
   done < /sdcard/test/yi-hack-v2.cfg
   echo
fi

# Telnet server activation (no authentication required)
if [ "$YI_HACK_TELNET_SERVER" = "YES" ]; then
   echo "### Activating telnet server ... ###"
   telnetd -l /bin/sh &
   echo
fi

# Launch ftp server
if [ "$YI_HACK_FTP_SERVER" = "YES" ]; then
   if [ -f /sdcard/test/v2/bin/tcpsvd ]; then
      echo "### Activating FTP server ... ###"
      /sdcard/test/v2/bin/tcpsvd -vE 0.0.0.0 21 ftpd -w / &
      sleep 1s
      echo
   fi
fi

# Main hack
rm -f "$YI_HACK_NATIVE_TRACES"
#if [ -f /sdcard/test/v2/bin/yihackv2.so ]; then
#   export LD_PRELOAD=/sdcard/test/v2/bin/yihackv2.so
#fi
if [ -f /sdcard/test/v2/bin/libyihackv2.so ]; then
   export LD_PRELOAD=/sdcard/test/v2/bin/libyihackv2.so
fi

# Mount config
mkdir -p /mnt/cfg
mount -t jffs2 /dev/mtdblock8 /mnt/cfg

# Launch expected startup
if [ "$YI_HACK_STARTUP_MODE" = "MODIFIED" ]; then
   if [ -f /sdcard/test/v2/scripts/startup_modified.sh ]; then
      /sdcard/test/v2/scripts/startup_modified.sh
   fi
else
   if [ -f /sdcard/test/v2/scripts/startup_official.sh ]; then
      /sdcard/test/v2/scripts/startup_official.sh
   fi
fi
