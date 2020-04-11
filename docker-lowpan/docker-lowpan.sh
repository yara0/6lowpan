#!/bin/bash

#Author: Yara Altehini

#load the kernel module for IEEE 802.15.4
sudo modprobe ieee802154_socket

if [ $# -lt 1 ]; 
	then 
	echo "The number of devices was not specified";
	exit 0
fi
#specify the number of devices 
DEVICES=$1
#specify the PAN ID | or change it to $2 if you want to take it from the argument
PANID=0xceef
#create wpan devices
sudo modprobe fakelb numlbs=$DEVICES

#build Docker image
sudo docker build --tag iot-device .

#LOOP
for (( INDEX=0; INDEX<DEVICES; INDEX++ ))
do 
#set docker container's name
NAME=iot$INDEX
PHY=phy$INDEX
WPAN=wpan$INDEX
LOWPAN=lowpan$INDEX

#run the container with privileged option and without specifying the network
sudo docker run --privileged -dit --net=none --name $NAME iot-device

#get the pid of the container
PID="$(sudo docker inspect -f '{{.State.Pid}}' $NAME)"

#access the container network namespace
sudo mkdir -p /var/run/netns
sudo ln -s /proc/$PID/ns/net /var/run/netns/$PID

#add wpan and lowpan interfaces inside the container 
sudo iwpan $PHY set netns name $PID
sudo ip netns exec $PID iwpan dev $WPAN set pan_id $PANID
sudo ip netns exec $PID ip link add link $WPAN name $LOWPAN type lowpan
sudo ip netns exec $PID ip link set $WPAN up
sudo ip netns exec $PID ip link set $LOWPAN up

#Enable ipv6 inside the container
sudo ip netns exec $PID sysctl -w net.ipv6.conf.all.disable_ipv6=0
sudo ip netns exec $PID sysctl -w net.ipv6.conf.default.disable_ipv6=0
sudo ip netns exec $PID sysctl -w net.ipv6.conf.lo.disable_ipv6=0
done
