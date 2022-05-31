#!/bin/sh

### This file is called by /etc/init.d/rcS, and is run before app_init.sh

exec 1> /opt/wz_mini/log/wz_post.log 2>&1

set -x

if [[ -e /tmp/dbgflag ]];then
	echo "debug mode, disabled"
	exit 0
fi

export WZMINI_CFG=/opt/wz_mini/wz_mini.conf

[ -f $WZMINI_CFG ] && source $WZMINI_CFG

echo "welcome to wz_post.sh"
echo "PID $$"

if [ -d /lib/modules ]; then
	echo "mount kernel modules"
	mount --bind /opt/wz_mini/lib/modules /lib/modules
fi

if [ -f /params/config/.product_config ]; then
	if cat /params/config/.product_config | grep WYZEC1-JZ; then
		V2="true"
	fi
fi

##RTSP SERVER INIT

if [[ "$RTSP_HI_RES_ENABLED" == "true" ]] ||  [[ "$RTSP_LOW_RES_ENABLED" == "true" ]] && ! [[ -e /tmp/dbgflag ]]; then
	if [[ "$RTSP_LOW_RES_ENABLED" == "true" ]] && [[ "$RTSP_HI_RES_ENABLED" == "true" ]]; then
	        if [[ "$V2" == "true" ]]; then
		        echo "load video loopback driver at video6 video7"
		        insmod /opt/wz_mini/lib/modules/3.10.14_v2/kernel/v4l2loopback_V2.ko video_nr=6,7
		else
		        echo "load video loopback driver at video1 video2"
		        insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/v4l2loopback.ko video_nr=1,2
		fi
	elif [[ "$RTSP_LOW_RES_ENABLED" == "true" ]]; then
	        if [[ "$V2" == "true" ]]; then
		        echo "load video loopback driver at video7"
		        insmod /opt/wz_mini/lib/modules/3.10.14_v2/kernel/v4l2loopback_V2.ko video_nr=7
		else
		        echo "load video loopback driver at video2"
	        	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/v4l2loopback.ko video_nr=2
		fi
	elif [[ "$RTSP_HI_RES_ENABLED" == "true" ]]; then
	        if [[ "$V2" == "true" ]]; then
		        echo "load video loopback driver at video6"
		        insmod /opt/wz_mini/lib/modules/3.10.14_v2/kernel/v4l2loopback_V2.ko video_nr=6
		else
		        echo "load video loopback driver at video1"
		        insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/v4l2loopback.ko video_nr=1
		fi
	fi

        cp /system/bin/iCamera /opt/wz_mini/tmp/.storage/
        mount -o ro,bind /opt/wz_mini/usr/bin/iCamera /system/bin/iCamera
fi

/opt/wz_mini/etc/init.d/wz_user.sh &

##LIBRARY DEBUG
#cp /opt/wz_mini/lib/uClibc.tar /tmp
#tar -xf /tmp/uClibc.tar -C /tmp
#mount --bind /tmp/lib /lib
#cp /system/bin/iCamera /opt/wz_mini/tmp/.storage/
#mount -o ro,bind /opt/wz_mini/usr/bin/iCamera-dbg /system/bin/iCamera