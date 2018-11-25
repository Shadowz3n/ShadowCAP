#!/bin/bash
# ShadowCAP
# @autor: Henrique Bissoli Silva (emp.shad@gmail.com)

exiting(){
	tput clear
	echo -e "${BOLD}Exiting..$NC"
	exit 1
}

# Check if is root
if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1	
fi

# User INFO
GETPEER=$(ip -f inet a|grep -oP "(?<=inet ).+(?=\/)" | grep peer)

# Check VPN
if [[ "$GETPEER" != '' ]]; then
	echo "Disable VPN to use this script" 1>&2
	exit 1
fi

IFACE=$(ip route |grep default |sed -e "s/^.*dev.//" -e "s/.proto.*//")
IP=$(hostname -I |cut -d' ' -f1)
MAC=$(ip a |awk '/ether/ {print $2}'|head -n 1)
IPRANGE=$(ip a s|grep -A8 -m1 MULTICAST|grep -m1 inet|cut -d' ' -f6)

echo $IPRANGE
