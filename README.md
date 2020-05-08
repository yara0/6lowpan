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

*  

```
$ sudo  
```

	Note:

* The expected result:

```



```

## Testing

* Check connectivity

	Use ifconfig to get the IPv6 addresses inside a container.
	```
	$ ifconfig
	```

	-Ping any IoT device from the 6LoWPAN network

	For example, ping device iot1 from device iot2.

	* Using the IPv6 link-local address

	```
	$
	$ ping6
	```

	* Using the subnet address
	The subnet of our 6LoWPAN network is fd2c:85e8:6a6b:dc2a::/64.

	```
	$ 
	$ ping6
	```

	-Ping a device in the Ethernet network from one of the IoT devices in the 6LoWPAN network

	```
	$ ping6
	```

Note: You can run Wireshark/tcpdump to observe the traffic but you need to install it.

* 


## References

* http://wpan.cakelab.org/
* https://docs.docker.com/get-started/overview/
* https://michael.stapelberg.ch/posts/2018-12-12-docker-ipv6/
* https://platform9.com/blog/container-namespaces-deep-dive-container-networking/
* https://simpledns.plus/private-ipv6


