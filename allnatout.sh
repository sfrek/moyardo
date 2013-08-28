#!/bin/bash
FPRE=/tmp/PREROUTING
TEMP=/tmp/TEMP
iptables -t nat -vnL PREROUTING > ${FPRE}
for IP in 85.10.230.88 85.10.230.89 85.10.230.90 85.10.230.91 85.10.230.92 85.10.230.93 85.10.230.94 85.10.230.95 
do
	echo -e "\033[01;32m${IP}\033[00m"
	# to:172.16.100.250 85.10.230.95 port:80
	awk '/'$IP'/ {print $(NF-1),$NF}' ${FPRE} | \
		awk -v ip=${IP}  '{print "bash desnating.sh ",substr($2,4),ip,substr($1,5)}' >> $TEMP
	# | xargs ./argumentos.sh

done
echo
. ${TEMP}
rm -f ${TEMP}
