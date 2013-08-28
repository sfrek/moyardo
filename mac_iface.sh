#!/bin/bash
IFACE=${1:-eth0}
set -x
ip addr show ${IFACE} | awk -v dev=${IFACE} '/master/ { bridge=$(NF-4) } 
	/inet\ / { red=$2 }
	/link\/ether/ {printf "%s\t%s\t%s\t%s\n",dev,toupper($2),red,bridge}'
set +x
