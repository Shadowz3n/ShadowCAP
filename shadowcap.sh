#!/bin/bash
# ShadowCAP
# @autor: Henrique Bissoli Silva (emp.shad@gmail.com)

# CTRL + C
exiting(){
	tput clear
	echo -e "${BOLD}Exiting..$NC"
	exit 1
}

# Check if is root
if [ "$(id -u)" != "0" ]; then
	echo "[✘] This script must be run as root" 1>&2
	exit 1
fi

# Check VPN
GETPEER=$(ip -f inet a|grep -oP "(?<=inet ).+(?=\/)" | grep peer)
if [[ "$GETPEER" != '' ]]; then
	echo "[✘] Disable VPN to use this script" 1>&2
	exit 1
fi

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Packets targeting port 80 is delivered to local app listening on 8080
iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 8080

# User INFO
IFACE=$(ip route |grep default |sed -e "s/^.*dev.//" -e "s/.proto.*//")
IP=$(hostname -I |cut -d' ' -f1)
MAC=$(ip a |awk '/ether/ {print $2}'|head -n 1)
NEWMAC=$(od -An -N6 -tx1 /dev/urandom | sed -e 's/^  *//' -e 's/  */:/g' -e 's/:$//' -e 's/^\(.\)[13579bdf]/\10/')
IPRANGE=$(ip a s|grep -A8 -m1 MULTICAST|grep -m1 inet|cut -d' ' -f6)

echo -e "\n[I] [$IFACE] $IP : $MAC ✔\n"
echo $NEWMAC
