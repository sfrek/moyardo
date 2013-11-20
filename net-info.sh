#!/bin/bash

# Este escript hace uso de:
#   - nast
#   - ipcalc

get_cdir(){
	# El argumento de entrada es el nombre de la red
	#   ejemplo: nGest
	virsh net-dumpxml  $1 > /tmp/net-dump.xml
	xmllint --xpath '//network/ip/@address' /tmp/net-dump.xml > /tmp/variables.net
	xmllint --xpath '//network/ip/@netmask' /tmp/net-dump.xml >> /tmp/variables.net
	. /tmp/variables.net
	# ahora tengo las variables $address y $netmask

	# Ahora viene el preguntar por el sistema operativo, ya que ipcalc
	# funciona de distinta manera según estes en debian/ubuntu fedora/redhat
	# debian: ipcalc $address $netmask
	# fedora: ipcalc -np 192.168.0.1 255.255.128.0
	os_base=$(lsb_release -si | tr [:upper:] [:lower:])
	case ${os_base} in
		debian|ubuntu)
			CDIR=$(ipcalc $address $netmask | awk '/Network/ {print $2}')
			;;
		fedora|redhat)
			ipcalc -np $address $netmask > /tmp/variables.ipcalc
			. /tmp/variables.ipcalc
			CIDR="$NETWORK/$PREFIX"
			;;
	esac
	echo $CDIR
}


## ____MAIN____ ##

[[ $# < 1 ]] && echo "Falta dominio" && exit 1

DOM=$1
TMPFILE=/tmp/${0%%.*}.temp

virsh domiflist $DOM | \
	awk '/([0-9a-fA-F][0-9a-fA-F]:){5}([0-9a-fA-F][0-9a-fA-F])/ {print $NF" "$3}' > ${TMPFILE}

while read MAC NET
do
	CDIR=$(get_cdir $NET)
	# fping -aq -g $CDIR 2>&- 1>&-
	# nmap -sP $CDIR 2>&- 1>&-
	# arp -an -i $NET | grep -i $MAC
	# nmap -n -sP -oX $CDIR
	# fping -aq -g $CDIR 2>&-
	echo "$DOM $MAC $NET"
	nast -i $NET -m | grep -i $MAC
done < ${TMPFILE}
