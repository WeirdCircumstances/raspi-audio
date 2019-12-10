#!/bin/sh

switch=0
oldtoggle=""

while [ 1 ]; do
  sleep 1
  file='/home/pi/raspi-audio/toggle.txt'
  while read toggle; do
    if [ "$toggle" != "$oldtoggle" ]; then
      if [ "$toggle" = "ON" ]; then
        mosquitto_pub -h localhost -t cmnd/anlage/POWER -m $toggle
	switch=0
        oldtoggle="ON"
      elif [ "$toggle" = "OFF" ] && [ "$switch" = 0 ]; then
	sleep 15
	switch=1
      elif [ "$toggle" = "OFF" ] && [ "$switch" = 1 ]; then
	mosquitto_pub -h localhost -t cmnd/anlage/POWER -m $toggle
	oldtoggle="OFF"
      fi
    fi
  done < $file
done
