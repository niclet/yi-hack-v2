#!/bin/sh
if [ $# -eq 4 ] && [ "$1" == "-o" ] && [ "$3" == "-q" ];
then
   TMPBASE=`mktemp -u`
   /usr/local/bin/test_yuvcap -b 0 -Y -f $TMPBASE -r 1
   if [ $? -eq 0 ];
   then
      YUV_FILE=`ls ${TMPBASE}*`
      # we get something like /tmp/tmp.xr8C1d_prev_M_1920x1080.yuv
      # we want to extract width and height
      YUV_FILE_SIZE=${YUV_FILE##/*_}
      # we get 1920x1080.yuv
      WIDTH=${YUV_FILE_SIZE%%x*}
      HEIGHT_YUV=${YUV_FILE_SIZE##*x}
      HEIGHT=${HEIGHT_YUV%%.*}
      # convert yuv to jpg
      /usr/local/bin/jpg_enc -y $YUV_FILE -w $WIDTH -h $HEIGHT -q $4 -f $2
      rm -f $YUV_FILE
   else
      echo "Failed to capture frame, please ensure that test_encode has been correctly started." 
   fi
else
   echo "Usage:  capture.sh -o <JPG output file> -q <quality>"
   echo "Sample: capture.sh -o /sdcard/test/capture.jpg -q 70"
fi
