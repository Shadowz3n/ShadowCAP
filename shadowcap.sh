#!/bin/bash
# ShadowCAP
# @autor: Henrique Bissoli Silva (emp.shad@gmail.com)

# Helpers
BOLD=$(tput bold)
NC=$(tput setab 9 && tput sgr0)
VERSION='0.0.1'

# CTRL + C
exiting(){
	tput clear
	echo -e "${BOLD}Exiting..$NC"
	service network-manager restart && wait;
	exit 1
}

# Check if is root
if [ "$(id -u)" != "0" ]; then
	echo "[${BOLD}✘${NC}] This script must be run as root" 1>&2
	exit 1
fi

# Check VPN
GETPEER=$(ip -f inet a|grep -oP "(?<=inet ).+(?=\/)" | grep peer)
if [[ $GETPEER ]]; then
	echo "[${BOLD}✘${NC}] Disable VPN to use this script" 1>&2
	exit 1
fi

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Packets targeting port 80 is delivered to local app listening on 8080
iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 8080

# Get interface
IFACE=$(ip route |grep default |sed -e "s/^.*dev.//" -e "s/.proto.*//")
NEWMAC=$(od -An -N6 -tx1 /dev/urandom | sed -e 's/^  *//' -e 's/  */:/g' -e 's/:$//' -e 's/^\(.\)[13579bdf]/\10/')

# Change to random MAC Address
echo -e "\n[${BOLD}I${NC}] [$IFACE] Random MAC Address"
service network-manager stop
ifconfig $IFACE down
ifconfig $IFACE hw ether $NEWMAC
ifconfig $IFACE up
service network-manager restart

wait;

# Get INFO
IP=$(hostname -I |cut -d' ' -f1)
MAC=$(ip a |awk '/ether/ {print $2}'|head -n 1)
IPRANGE=$(echo $IP | cut -d'.' -f -1,2,3)

# Targets array
TARGETS=()

# Display INFO
echo -e "\n[${BOLD}I${NC}] [$IFACE] $IP : $MAC ✔\n"

# Check hosts alive
echo -e "[${BOLD}I${NC}] Checking hosts alive:\n"
for ip in "$IPRANGE".{1..254}; do
	THISARP=$(arp -n $ip | grep ether)
	if [[ $THISARP ]]; then
		ARPRESULT=$(echo $THISARP|cut -d' ' -f -1,3) && echo $ARPRESULT && TARGETS+=$ARPRESULT
	fi
done

for target in $TARGETS; do
	echo $target
done

#
#echo "IPS: $TARGETS"
