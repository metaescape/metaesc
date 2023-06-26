#!/usr/bin/env bash
var1=$1
[ -z "$var1" ] && var1="0"

brightness_file=/sys/class/backlight/amdgpu_bl0/brightness
mod=$(stat -c "%a" $brightness_file)
if [ $mod -ne 646 ]; then
    PASSWD="$(zenity --password --title=Authentication)"
    echo -e $PASSWD | sudo -S chmod 646 $brightness_file
fi
var1=$(($var1 + $(cat $brightness_file)))
[ $var -gt 255 ] && var1=255 #max brightness is 255
echo $var1 > $brightness_file
notify-send -t 500 "🌟 $var1"
