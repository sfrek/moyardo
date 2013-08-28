#!/bin/bash
# Scritp para hacer backup de las máquinas virtuales de moya a nostromo
# Version 0.1 -> poco elegante y rápida.
#
# Lo primero "config" para el ssh:
# root@moya ~/scripts # grep -A3 nostromo ~/.ssh/config 
# host nostromo
#	hostname nostromo.abadasoft.com
#	user sistemas.hf
#	port 22822
#
# Con esto pasamos de:
# rsync -vrPtza --rsh='ssh -p22822' --progress --log-file=/home/zen/rsync.log /dir user@destino:/dir/
# a:
# rsync -vrPtza --progress --log-file=/home/zen/rsync.log /dir destino


# ojo DIR_REMOTO debe existir y el ususario de conexión debe tener permisos de escritura.
DIR_REMOTO=/backup
LOG=/tmp/backups_mvs.log

echo "----- Backup Máquinas virtuales en Moya [ $(date +%x" "%X) ] -----" > ${LOG}
echo >> ${LOG}

echo "[ $(date +%X) ] ++++++++++ Directorio /etc/libvirt ++++++++++++++++ " >> ${LOG}
# /etc/libvirt
echo "[ $(date +%X) ] ssh nostromo \"[ ! -d ${DIR_REMOTO}/etc ] && mkdir ${DIR_REMOTO}/etc\"" >> ${LOG}
ssh nostromo "[ ! -d ${DIR_REMOTO}/etc ] && mkdir ${DIR_REMOTO}/etc"

# echo "[ $(date +%X) ] rsync -vrPtza --progress --log-file=/var/log/rsync.etc.libvirt.log \
#	/etc/libvirt nostromo:${DIR_REMOTO}/etc/" >> ${LOG}
# rsync -vrPtza --progress --log-file=/var/log/rsync.etc.libvirt.log \
#	/etc/libvirt nostromo:${DIR_REMOTO}/etc/


echo "[ $(date +%X) ] ++++++++++ Directorio /var/lib/libvirt ++++++++++++++++ " >> ${LOG}
# /var/lib/libvirt
echo "[ $(date +%X) ] ssh nostromo \"[ ! -d ${DIR_REMOTO}/var/lib ] && mkdir -p ${DIR_REMOTO}/var/lib\"" >> ${LOG}
ssh nostromo "[ ! -d ${DIR_REMOTO}/var/lib ] && mkdir -p ${DIR_REMOTO}/var/lib"

echo "[ $(date +%X) ] rsync -vrPtza --progress --log-file=/var/log/rsync.var.lib.libvirt.log \
	/var/lib/libvirt nostromo:${DIR_REMOTO}/var/lib/" >> ${LOG}
rsync -vrPtza --progress --log-file=/var/log/rsync.var.lib.libvirt.log \
	/var/lib/libvirt nostromo:${DIR_REMOTO}/var/lib/

# Pausamos máquinas encendidas
echo >> ${LOG}
echo "[ $(date +%X) ] ++++++++++ Pausamos y Resincronizamos ++++++++++++++++ " >> ${LOG}
for MV in $(virsh -q list | awk '{print $2}')
do
	echo "[ $(date +%X) ] virsh suspend ${MV}" >> ${LOG}
	virsh suspend $MV
	for IMG in $(virsh -q domblklist ${MV} | awk '/images/ {print $2}')
	do
		echo " + [ $(date +%X) ] rsync ${IMG} de ${MV}" >> ${LOG}
		rsync -vrPtza --progress --log-file=/var/log/rsync.var.lib.libvirt.log \
			${IMG} nostromo:${DIR_REMOTO}/${IMG}
		echo "   + [ $(date +%X) ] md5sum ${IMG} := $(md5sum ${IMG})" >> ${LOG}
		echo "   + [ $(date +%X) ] ssh nostromo \"md5sum ${DIR_REMOTO}/${IMG}\" := $(ssh nostromo md5sum ${DIR_REMOTO}/${IMG})" >> ${LOG}
	done
	echo "[ $(date +%X) ] virsh resume ${MV}" >> ${LOG}
	virsh resume $MV
done

echo >> ${LOG}
echo "[ $(date +%X) ] Listado de máquinas" >> ${LOG}
virsh list --all >> ${LOG}
mail -s "[ $(date +%X) ] backup máquinas virtuales en moya" sistemas@abadasoft.com < ${LOG}
