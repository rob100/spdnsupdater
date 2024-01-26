#!/bin/bash

# load last IP
LASTIP=0.0.0.0
LASTIP6=0:0:0:0:0:0:0:0

if [ -f /tmp/lastip ]; then
	echo "import lastip"
	source /tmp/lastip
	echo "last ip was $LASTIP"
fi

if [ -f /tmp/lastip6 ]; then
	echo "import lastip6"
	source /tmp/lastip6
	echo "last ipv6 was $LASTIP6"
fi

#get current ip
# ip -4 addr show eth0 | grep inet | awk '{print $2}' | cut -d/ -f1
IP=$(curl -s http://checkip4.spdyn.de/)
echo "current IPv4 is $IP"
# ip -6 addr show eth0 | grep inet6 | awk -F '[ \t]+|/' '{print $3}' | grep -v ^::1 | head -n 1
# ip -6 addr show eth0 | grep inet6 | awk -F '[ \t]+|/' '{print $3}'
IP6=$(curl -s http://checkip6.spdyn.de/)
echo "current IPv6 is $IP6"

#check if ipv4 and ipv6 are the same
if [[ "$IP" = "$LASTIP" && "$IP6" = "$LASTIP6"]]; then
	echo "no ip change"
	exit
else
	echo "force ip update"
fi

#update string
updateip() {
	RETURNCODE=$(curl -s --user $1:$2 "https://update.spdyn.de/nic/update?hostname=$1&myip=$IP&pass=$2")
	evalResult $RETURNCODE
	RETURNCODE=$(curl -s --user $1:$2 "https://update.spdyn.de/nic/update?hostname=$1&myip=$IP6&pass=$2")
	evalResult $RETURNCODE
}

evalResult() {
	# eval return code
	case $1 in

	nochg*)
		echo "update done... IP was up2date"
		;;

	good*)
		echo "update done... IP changed to $IP"
		;;

	abuse*)
		echo >&2 "update failed: abuse error"
		exit
		;;

	badauth*)
		echo >&2 "update failed: wrong user or password"
		exit
		;;

	numhost*)
		echo >&2 "update failed: you try to update more as 20 hosts"
		exit
		;;

	notfqdn*)
		echo >&2 "update failed: host is not a FQDN"
		exit
		;;

	!yours*)
		echo >&2 "update failed: host is not assigned to your account"
		exit
		;;

	fatal*)
		echo >&2 "update failed: host is disabled"
		exit
		;;

	nohost*)
		echo >&2 "update failed: host not available or deleted"
		exit
		;;

	esac

}

# load domains and passwords from spdnsupdater.conf
if [ -f ~/.spdnsupdater.conf ]; then
	echo "import config from ~/.spdnsupdater.conf "
	source ~/.spdnsupdater.conf
else
	echo "conf file \"$HOME/.spdnsupdater.conf\" not found"
	exit
fi

# calc end for sequence
e=$(($(echo ${DOMAIN[*]} | wc -w) - 1))

#perform update
for ((i = 0; i <= $e; i++)); do
	echo " "
	echo "Update domain ${DOMAIN[$i]}"
	updateip ${DOMAIN[$i]} ${PASSWORD[$i]}
	echo " "
done
echo "LASTIP=$IP" >/tmp/lastip
echo "LASTIP6=$IP6" >/tmp/lastip6

exit
