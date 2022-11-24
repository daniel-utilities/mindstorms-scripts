#!/usr/bin/env bash

TYPE=$1
SERIAL=$2
KERNEL=$3
MAJOR=$4
MINOR=$5

if [ -x "$(command -v docker)" ]; then
  CONTAINER_IDS=$(docker ps -qf ancestor=nxtosek -f status=running)
fi

LOGFILE_DIR="/tmp/nxt"
LOGFILE="nxt-events.log"

mkdir -p "$LOGFILE_DIR"
echo "USB Event: 
  ACTION:   $ACTION
  DEVTYPE:  $DEVTYPE
  TYPE:     $TYPE
  KERNEL:   $KERNEL
  SERIAL:   $SERIAL
  DEVNUM:   $DEVNUM
  DEVNAME:  $DEVNAME
  DEVLINKS: $DEVLINKS
  DEVPATH:  $DEVPATH
  MAJOR:    $MAJOR
  MINOR:    $MINOR
  Docker Containers: $CONTAINER_IDS
" >> "$LOGFILE_DIR/$LOGFILE"

# If any NXTOSEK containers are running, add this device to them.
if [ $ACTION == "add" ]; then
  split(){ CONTAINER_IDS=( $CONTAINER_IDS ); }
  IFS=$'\n' split
  for CONTAINER in ${CONTAINER_IDS[@]}; do
    docker exec -u 0 $CONTAINER mknod $DEVNAME c $MAJOR $MINOR
    docker exec -u 0 $CONTAINER chmod -R 777 $DEVNAME
  done
fi

# ALIAS=""
# SERIAL=$1
# 
# LOGFILE_DIR="/tmp/nxt"
# LOGFILE="nxt-events.log"
# 
# ALIASES="/etc/udev/bricks.dat"
# 
# ALIAS_DATFILE_DIR="/tmp/nxt/alias"
# DEVNUM_DATFILE_DIR="/tmp/nxt/devnum"
# DEVNUM_DATFILE="$DEVNUM_DATFILE_DIR/$DEVNUM.dat"
# 
# 
# # USB EVENT: ADD
# if [[ $ACTION == "add" ]] && [[ $DEVTYPE == "usb_device" ]]; then
# 	# Map SERIAL to ALIAS using the nexttool file:
# 	while read -r line; do
# 		if [[ "$line" == *"$SERIAL"* ]]; then
# 			read -d '=' ALIAS <<< "$line"
# 		fi
# 	done < "$ALIASES"
# 	# Create a temporary file to remember this NXT by its DEVNUM
# 	mkdir -p $DEVNUM_DATFILE_DIR
# 	echo -e "ALIAS=$ALIAS\nSERIAL=$SERIAL\nDEVNUM=$DEVNUM\nDEVNAME=$DEVNAME\nDEVLINKS=$DEVLINKS" > $DEVNUM_DATFILE
# 
# 
# # USB EVENT: BIND
# elif [[ $ACTION == "bind" ]] && [[ $DEVTYPE == "usb_device" ]]; then
# 	source "$DEVNUM_DATFILE"
# 	if [[ "$ALIAS" != "" ]]; then
# 		ALIAS_DATFILE="$ALIAS_DATFILE_DIR/$ALIAS.dat"
# 		# Create a temporary file to remember this NXT by its ALIAS
# 		mkdir -p $ALIAS_DATFILE_DIR
# 		echo -e "ALIAS=$ALIAS\nSERIAL=$SERIAL\nDEVNUM=$DEVNUM\nDEVNAME=$DEVNAME\nDEVLINKS=$DEVLINKS" > $ALIAS_DATFILE
# 	fi
# 
# 
# # USB EVENT: UNBIND
# elif [[ $ACTION == "unbind" ]] && [[ $DEVTYPE == "usb_device" ]]; then
# 	source "$DEVNUM_DATFILE"
# 	if [[ "$ALIAS" != "" ]]; then
# 		ALIAS_DATFILE="$ALIAS_DATFILE_DIR/$ALIAS.dat"
# 		rm "$ALIAS_DATFILE"
# 	fi
# 
# 
# # USB EVENT: REMOVE
# elif [[ $ACTION == "remove" ]] && [[ $DEVTYPE == "usb_device" ]]; then
# 	source "$DEVNUM_DATFILE"
# 	rm "$DEVNUM_DATFILE"
# fi
# 
# mkdir -p $LOGFILE_DIR
# echo "USB Event: 
# ACTION:   $ACTION
# DEVTYPE:  $DEVTYPE
# ALIAS:    $ALIAS
# KERNEL:   $KERNEL
# SERIAL:   $SERIAL
# DEVNUM:   $DEVNUM
# DEVNAME:  $DEVNAME
# DEVLINKS: $DEVLINKS
# DEVPATH:  $DEVPATH
# " >> "$LOGFILE_DIR/$LOGFILE"
# 