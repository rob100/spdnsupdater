#!/bin/bash

# load last IP
LASTIP6=0:0:0:0:0:0:0:0

if [ -f /tmp/lastip6 ]; then
	echo "import lastip6"
	source /tmp/lastip6
	echo "last ipv6 was $LASTIP6"
fi

#get current ip
IP6=$(curl -s http://checkip6.spdyn.de/)
#IP6=$(ip -6 addr show eth0 | grep inet6 | awk -F '[ \t]+|/' '{print $3}' | grep -v ^::1 | head -n 1)
echo "current IPv6 is $IP6"

#check if ipv6 are the same
if [ "$IP6" = "$LASTIP6" ]; then
	echo "no ip change"
	exit
else
	echo "force ip update"
fi

#update string
updateip() {
	echo "Updating IPv6"
	RETURNCODE=$(curl -s --user $1:$2 "https://update.spdyn.de/nic/update?hostname=$1&myip=$IP6&pass=$2")
	evalResult $RETURNCODE
}

evalResult() {
	# eval return code
	case $1 in

	nochg*)
		echo "update done... IP was up-to-date"
		;;

	good*)
		echo "update done... IP changed"
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
echo "LASTIP6=$IP6" >/tmp/lastip6

exit
