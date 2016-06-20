#!/bin/bash

# get IP
LASTIP=0.0.0.0

if [ -f /tmp/lastip ];then
	echo "import lastip"
	source /tmp/lastip
	echo "last ip was $LASTIP"
fi



#get current ip
IP=$(curl -s http://checkip4.spdyn.de/)
echo "Current IP is $IP"



#check ip and last check
if [ "$IP" = "$LASTIP" ];then
	if [ "$LASTCHECK" -le "$(( $(date +%s) - 86400 ))" ];then
		echo "force ip update"
	else
	echo "no ip change"
	exit
	fi
fi


echo "LASTIP=$IP" > /tmp/lastip
echo "LASTCHECK=$(date +%s)" >> /tmp/lastip

#update string
updateip(){
curl --user $1:$2 "https://update.spdyn.de/nic/update?hostname=$1&myip=$IP&pass=$2"
}

# load domains and passwords from spdnsupdater.conf
if [ -f ~/.spdnsupdater.conf ];then
	echo "import config from ~/.spdnsupdater.conf "
	source ~/.spdnsupdater.conf 
else
	echo "conf file not found"
	exit
fi

# cal end for sequence
e=$(( $(echo ${DOMAIN[*]} | wc -w) - 1 )) 


#perform update
for (( i=0; i<=$e; i++ ));do
	echo " "
	echo "Update domain ${DOMAIN[$i]}"
	updateip ${DOMAIN[$i]} ${PASSWORD[$i]}
	echo " "
done



exit