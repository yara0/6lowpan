#!/bin/bash

#Author: Yara Altehini

if [ $# -lt 1 ]; 
	then 
	echo "The number of devices was not specified";
	exit 0
fi

#specify the number of devices 
DEVICES=$1

#stop and remove the running containers 
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

sudo rmmod ieee802154_socket
sudo rmmod fakelb
sudo rmmod mac802154
sudo rmmod ieee802154
sudo rmmod ieee802154_6lowpan

