#!/bin/bash

# 6LoWPAN Simulator
# Author: Yara Altehini

#install prerequisites
#sudo ./requirements.sh > log/requirementslog.txt 2>&1

#run the simulator

figlet -f big 6LoWPAN Simulator
echo $'--------------- Yara Altehini ---------------\n\n'

if [ $# -lt 1 ]; 
	then 
	echo "The number of devices was not specified";
	exit 0
fi

sudo ./cleanup-docker-lowpan.sh $1 > log/cleanuplog.txt 2>&1
sudo ./docker-lowpan.sh $1 > log/docker-lowpanlog.txt 2>&1


#check if the simulator is running without any problems

RESULT="$(sudo docker container exec iot0 ifconfig -a | grep 'wpan0')"

if [ -z "$RESULT" ]
then
      echo $' The simulator failed to run. \n Please run the simulator again.'
else
      echo $' The simulator ran successfully. \n'
fi


