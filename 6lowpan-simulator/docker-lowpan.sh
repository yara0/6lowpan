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


#subnetting

sudo ip netns exec $PID ip -6 addr add fd2c:85e8:6a6b:dc2a::100$INDEX/64 dev $LOWPAN

#let the first decive (which is has an index 0) be the gateway for the rest devices
#enable ipv6 forwarding on the gateway
if [ $INDEX -ne 0 ]; 
	then
	sudo ip netns exec $PID ip -6 route add default via fd2c:85e8:6a6b:dc2a::1000 dev $LOWPAN
	else
   	sudo ip netns exec $PID sysctl net.ipv6.conf.all.forwarding=1
   	sudo ip netns exec $PID sysctl -p /etc/sysctl.conf
   	#setting an eth interface in the gateway 
   	VETH=veth-$NAME
	VPEER=vpeer-$NAME

	MAC_ADDR=openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//'

	sudo ip link add $VETH type veth peer name $VPEER
	sudo ip -6 addr add fdec:10ba:eedd:5970::5002/64 dev $VETH
	sudo ip link set $VETH up

	sudo ip link set $VPEER netns $PID
	sudo ip netns exec $PID ip link set dev $VPEER name eth0
	sudo ip netns exec $PID ip link set eth0 address $MAC_ADDR
	sudo ip netns exec $PID ip link set eth0 up
	sudo ip netns exec $PID ip addr add 10.15.1.1/16 dev eth0
	sudo ip netns exec $PID ip -6 addr add fdec:10ba:eedd:5970::5001/64 dev eth0
	sudo ip netns exec $PID ip -6 route add default via fdec:10ba:eedd:5970::5002 dev eth0

	sudo route add -6  fd2c:85e8:6a6b:dc2a::/64 gw fdec:10ba:eedd:5970::5001 dev veth-iot0
fi

done

