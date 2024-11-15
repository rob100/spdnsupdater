### What is it for?
This bash script is to be used for the Securepoint Dynamic DNS Service (https://www.spdns.de/, https://www.spdyn.de/).

### How to use?
Add your domain and password/updateToken under `~/.spdnsupdater.conf`
Example:
```
DOMAIN=(dmxxxx.spdns.eu dyxxxx.spdns.eu qxxxx.spdns.eu upxxxx.spdns.eu)
PASSWORD=(ieya-xxxxx qsto-xxxxxx mnuq-xxxxx zfoy-xxxxx)
```
Run the script `bash spdnsupdater.sh`

### How it works?
1.	Load “lastip” from /tmp/lastip (if available)
2.	Get the current ip adress from “http://checkip4.spdyn.de/”
3.	Check if the ip was changed (since the last run)
4.	Checks when the last update was done (atm after 24h the script force the ip update).
5.	Save “lastip”  to /tmp/lastip
6.	Load conf file
7.	Perform the ip update (if the ip was changed or the last check is older as 24h

### Update 01/25/24
- Added IPv6 support (If domain name is compatible both IPv4 and IPv6 will be set)
