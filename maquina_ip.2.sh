#!/bin/bash

iface_mac_ip() {
	IFACE=${1:-eth0}
	set -x
	ip addr show ${IFACE} | awk -v dev=${IFACE} '/master/ { bridge=$(NF-4) } 
		/inet\ / { red=$2 }
		/link\/ether/ {printf "%s\t%s\t%s\t%s\n",dev,toupper($2),red,bridge}'
	set +x
}

NOW=$(date +%s)
DOMS=/tmp/$0.${NOW}.doms
MACS=/tmp/$0.${NOW}.macs
BRID=/tmp/$0.${NOW}.brid
IPS=/tmp/$0.${NOW}.ips
PATTERN=${1:-''}

virsh -q list | awk '/'${PATTERN}'/ {print $2}' > ${DOMS}
sort -i ${DOMS} | uniq > ${DOMS}.sort

for DOM in $(cat ${DOMS}.sort)
do
	virsh -q domiflist ${DOM} | \
		awk -v dom=${DOM} '/network/ {print toupper($NF),$1,dom}' >> ${MACS} 
done
sort -i ${MACS} | uniq > ${MACS}.sort

for DEV in $( awk '{print $2}' ${MACS} )
do
	ip addr show ${DEV} | awk -v dev=${DEV} '/master/ { print dev,$(NF-4) }' >> ${BRID}
done

for BRIDGE in $(cut -d' ' -f2 ${BRID} | sort -i | uniq )
do
	echo -en "\033[01;32mComprobando ${BRIDGE}\033[00m"
	nast -i ${BRIDGE} -m 2>&-| awk -v bridge=${BRIDGE} '/\([0-9]{1,3}/ {print $1,bridge,$2}' >> ${IPS}
	echo -e " \033[01;33m$(grep -c ${BRIDGE} ${IPS}) IPs"
done 
sort -i ${IPS} | uniq > ${IPS}.sort

echo -e "\033[01;33mMáquinas Virtuales\033[00m"
join ${IPS}.sort ${MACS}.sort | awk '{print $5,$4,$2,$3,$1}' | sort | tee /tmp/maquinas.${NOW}
echo -e "\033[01;32mConsulta en fichero: \033[01;37m/tmp/maquinas.${NOW}\033[00m"

rm -f ${DOMS} ${DOMS}.sort ${MACS} ${MACS}.sort ${BRID} ${IPS} ${IPS}.sort
