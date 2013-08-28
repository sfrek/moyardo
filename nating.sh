#!/bin/bash

usage() {
	cat << __EOF__
Usage: $0 <virtual machine ip> <pubilc ip> <ports>

__EOF__
}

[ $# -lt 3 ] && echo fail && usage && exit 1

VM_IP=${1:-IP_VM}
shift
PUBLIC_IP=${1:-IP_PUBLIC}
shift
PORTS=${@:-22}

echo "VM_IP     : ${VM_IP}"
echo "PUBLIC_IP : ${PUBLIC_IP}"
echo "PORTS     : ${PORTS}"

# FIXME: Chapucilla para activar la ip pública
ip addr add ${PUBLIC_IP}/32 dev br0

for PORT in ${PORTS}
do
	echo -e "\033[01;32mnat ${PUBLIC_IP}:${PORT} to ${VM_IP}:${PORT}\033[00m"
	iptables -I FORWARD 1 -d ${VM_IP} -p tcp -m state --state NEW,RELATED,ESTABLISHED \
		-m tcp --dport ${PORT} -j ACCEPT
	iptables -t nat -A PREROUTING -p tcp --dport ${PORT} -d ${PUBLIC_IP} \
		-j DNAT --to ${VM_IP}
done
