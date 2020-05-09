# 6LoWPAN Simulator

The project is for research and education use. It is an IoT simulator based on 6LoWPAN. The simulator simulates a 6LoWPAN network that connects to an Ethernet network through an edge router. In the 6LoWPAN network, each IoT device is a Docker container (with Ubuntu image) that has 6lowpan and WPAN interfaces, except for the edge router which has, in addition to 6lowpan and WPAN interfaces, an Ethernet interface to connect to the Ethernet network. The simulator can be used as a testing environment for 6LoWPAN applications, and since each IoT device is a Docker container, it can be customized based on application needs.


## Authors

* **Yara Altehini**

## Technologies

* IPv6
* 6LoWPAN
* IEEE 802.15.4
* Docker
* Linux Namespaces
* Linux WPAN

## Tested Environment

* Ubuntu 18.04.4 LTS

## Getting Started

### Prerequisites

* Install Docker Engine from [here](https://docs.docker.com/engine/install/ubuntu/)
* Enable IPv6 on Docker:

1. Edit /etc/docker/daemon.json with the following content 
```
{
      "ipv6": true,
      "fixed-cidr-v6": "2001:db8:1::/64"
}

```
2. Reload the Docker configuration file

```
$ sudo systemctl reload docker

```
* Run requirements.sh script which installs all other tools that are needed before running the simulator.

```
$ sudo ./requirements.sh 
```

### Running The Simulator

You need to specify the number of the IoT devices you want in the 6LoWPAN network. The IoT devices (containers) are numbered from iot0 to iot(n-1), where n is the number you provided when running the simulator. iot0 is the edge router in the 6LoWPAN network.

*  The following command runs the simulator with 4 IoT devices (containers)

```
$ sudo ./simulator-run.sh 4 
```

 The expected result:

```

   __  _       __          _______        _   _ 
  / / | |      \ \        / /  __ \ /\   | \ | |
 / /_ | |     __\ \  /\  / /| |__) /  \  |  \| |
| '_ \| |    / _ \ \/  \/ / |  ___/ /\ \ | . ` |
| (_) | |___| (_) \  /\  /  | |  / ____ \| |\  |
 \___/|______\___/ \/  \/   |_| /_/    \_\_| \_|
                                                
                                                
  _____ _                 _       _             
 / ____(_)               | |     | |            
| (___  _ _ __ ___  _   _| | __ _| |_ ___  _ __ 
 \___ \| | '_ ` _ \| | | | |/ _` | __/ _ \| '__|
 ____) | | | | | | | |_| | | (_| | || (_) | |   
|_____/|_|_| |_| |_|\__,_|_|\__,_|\__\___/|_|   
                                                
                                                
--------------- Yara Altehini ---------------


 The simulator ran successfully. 

```

* List all IoT containers

```
$ sudo docker container ls  
```

* To access a specific IoT container

```
$ sudo docker container exec -it (IoT container's name) /bin/bash
```

## Testing

* Check connectivity

	Use ifconfig to get the IPv6 addresses inside a container.
	```
	$ sudo docker container exec (IoT container's name) ifconfig
	```

	-Ping any IoT device from the 6LoWPAN network

	For example, ping device iot1 from device iot2.

	* Using the IPv6 link-local address
  

	```
	$ sudo docker container exec iot2  ping6 fe80::6857:9a70:4591:fb7%lowpan2
	```

	* Using the subnet address
	
  The subnet of our 6LoWPAN network is fd2c:85e8:6a6b:dc2a::/64.

	```
	$ sudo docker container exec iot2  ping6 fd2c:85e8:6a6b:dc2a::1001
	```

	-Ping a device in the Ethernet network (with subnet fdec:10ba:eedd:5970::/64) from one of the IoT devices in the 6LoWPAN network. The following command pings fdec:10ba:eedd:5970::5002 (which is veth-iot0 interface in the host) from device iot1.

	```
	$ sudo docker container exec iot1 ping6 fdec:10ba:eedd:5970::5002
	```

	-You can run tcpdump to observe the traffic
	
	```
	$ sudo docker container exec iot0 tcpdump
	```


## References

* http://wpan.cakelab.org/
* https://docs.docker.com/get-started/overview/
* https://michael.stapelberg.ch/posts/2018-12-12-docker-ipv6/
* https://platform9.com/blog/container-namespaces-deep-dive-container-networking/
* https://simpledns.plus/private-ipv6



