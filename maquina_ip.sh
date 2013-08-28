#!/bin/bash
DOMS=/tmp/$0.$(date +%s).doms
MACS=/tmp/$0.$(date +%s).macs
BRID=/tmp/$0.$(date +%s).brid
IPS=/tmp/$0.$(date +%s).ips

echo -e "\033[01;33mMáquinas Virtuales Activas\033[00m"
virsh list | awk '/running/ {print $2}' | tee ${DOMS}
echo

for DOM in $(cat ${DOMS})
do
	virsh domiflist ${DOM} | awk -v dom=${DOM} '/network/ {print toupper($NF),$1,dom}' >> ${MACS}

	# root@moya ~/old/scripts # ip a show vnet0
	# 16: vnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master nGreen state UNKNOWN qlen 500
	#    link/ether fe:54:00:d9:44:16 brd ff:ff:ff:ff:ff:ff
	#    inet6 fe80::fc54:ff:fed9:4416/64 scope link 
	#    valid_lft forever preferred_lft forever
	# root@moya ~/old/scripts # ip a show vnet0 | awk '/master/ {print NF}'
	# 13
	# root@moya ~/old/scripts # ip a show vnet0 | awk '/master/ {print $(NF-4)}'
	# nGreen
	MAC=$(tail -1 ${MACS} | awk '{print $1}')
	DEV=$(tail -1 ${MACS} | awk '{print $2}')
	ip a show ${DEV} | awk -v m=${MAC} '/master/ {print m,$(NF-4)}' >> ${BRID}

	# root@moya ~/old/scripts # nast -i nGreen -m | awk '/^[A-F0-9][A-F0-9]:/ {print}'
	# 52:54:00:E8:D6:25	172.16.100.1 (172.16.100.1) (*)
	# 52:54:00:28:D9:CC 	172.16.100.81 (172.16.100.81)
	# 52:54:00:12:50:4A 	172.16.100.82 (api.oneiric.abadasoft.com)
	# Mejor así
	# root@moya ~/old/scripts # nast -i nGreen -m | sed 's/\t/\ /' |  awk '/^[A-F0-9][A-F0-9]:/ {print $1,$2}'
	# 52:54:00:E8:D6:25 172.16.100.1
	# 52:54:00:28:D9:CC 172.16.100.81
	# 52:54:00:12:50:4A 172.16.100.82

	# DEV=$(tail -1 ${BRID} | awk '{print $2}')
	# nast -i ${DEV} -m | awk '/^[A-F0-9][A-F0-9]:/ {print $1,$2}' >> ${IPS}

done

for DEV in $( awk '{print $2}' ${BRID} )
do
	nast -i ${DEV} -m | awk '/^[A-F0-9][A-F0-9]:/ {print $1,$2}' >> ${IPS}
done



# modo chulo de "join" de achivos liena a linea
# awk 'NR==FNR{a[FNR]=$0;next} {print a[FNR],$0}' ${MACS} ${BRID}

sort ${MACS} | uniq > ${MACS}.2
sort ${BRID} | uniq > ${BRID}.2
sort ${IPS} | uniq > ${IPS}.2

echo ${MACS}.2 ${BRID}.2 ${IPS}.2
# cat ${MACS}.2 ${BRID}.2 ${IPS}.2
awk 'NR==FNR{a[FNR]=$0;next} {print a[FNR],$0}' ${MACS}.2 ${IPS}.2

# join -1 ${IPS}.2 ${BRID}.2
