#!/bin/bash
# script para levantar snort + barnyard2 + ossim-agent

. /lib/lsb/init-functions

snort_start(){
	BINARIO=$1
	INTERFAZ=$2
	CONFIGURACION=$3
	echo -e "\033[01;32mStarting ${BINARIO}\033[00m"
	${BINARIO} -i ${INTERFAZ} -c ${CONFIGURACION} -D
	sleep 1
}

barny_start(){
	BINARIO=/usr/local/bin/barnyard2
	INTERFAZ=$1
	CONFIGURACION=$2
	echo -e "\033[01;33mStarting ${BINARIO}\033[00m"
	${BINARIO} -c ${CONFIGURACION} -d /var/log/snort \
		-f snort_${INTERFAZ} \
		-w /var/log/snort/barnyard_${INTERFAZ}.waldo \
		--alert-on-each-packet-in-stream -e -D
}

ossim-agent_start(){
	BINARIO="/usr/bin/python -OOt /usr/local/bin/ossim-agent"
	OPCIONES="-d -c /etc/ossim/agent/config.cfg"
	echo -e "\033[01;34mStarting ${BINARIO}\033[00m"
	${BINARIO} ${OPCIONES}
}

is_running(){
	PID_FILE=$1
	NAME=$2
	if pidofproc -p "${PID_FILE}" >/dev/null; then
		log_action_end_msg 0 "${NAME} running"
	else
		if [ -e "${PID_FILE}" ]; then
			log_action_end_msg 1 "${NAME} failed"
		else
			log_action_end_msg 0 "${NAME} not running"
		fi
	fi
}

kill_process(){
	PID_FILE=$1
	DAEMON=$2
	killproc -p ${PID_FILE} ${DAEMON}
	log_progress_msg ${DAEMON}
}


HOST=$(hostname -s)
SCRIPT_DIR=/root/scripts
TEMPLATES=${SCRIPT_DIR}/templates
SNORT_CONF_DIR=/etc/snort
INTERFACES="br0 nGreen nServ nGest nImasD"
SNORT_BIN=/usr/sbin/snort

case $1 in
	start)
		pushd ${SCRIPT_DIR} 2>&- 1>&-
		for NET in ${INTERFACES}
		do
			# Colocamos la interfaz en modo promiscuo
			ip link set dev ${NET} promisc on

			# Obtenemos la HOME_NET asociada a la interfaz ${NET}
			inet=$(ip addr show ${NET} | awk '/inet\ / {print $2}' | awk -F'/' '{print $1}')
			
			# Solo en debian:
			NETWORK=$(ipcalc -n ${inet} | awk '/Network/ {print $2}')

			MASK=$(echo ${NETWORK} | cut -d'/' -f2)
			NETWORK=$(echo ${NETWORK} | cut -d'/' -f1)
			CIDR="${NETWORK}\/${MASK}"
			sleep 2

			# Creamos el binaro de snort para la Interfaz
			IFACE_SNORT=${SNORT_BIN}_${NET}
			[ ! -f ${IFACE_SNORT} ] && cp -a ${SNORT_BIN} ${IFACE_SNORT}

			# Parseamos el template de la configuración de snort
			SNORT_CONF=${SNORT_CONF_DIR}/snort.${NET}.conf
			sed 's/%INTERFACE%/'"${NET}"'/g' ${TEMPLATES}/snort.conf.tmpl | \
				sed 's/%HOME_NET%/'"${CIDR}"'/g' > ${SNORT_CONF}

			snort_start ${IFACE_SNORT} ${NET} ${SNORT_CONF}

			# Preparamos fichero de configuración para barnyard2
			# BARNY_CONF=${SCRIPT_DIR}/configs/barnyard2.${NET}
			# sed 's/%HOSTNAME%/'"${HOST}"'/g' ${TEMPLATES}/barnyard2.tmpl | \
			# 	sed 's/%INTERFACE%/'"$NET"'/g' > ${BARNY_CONF}
			# barny_start ${NET} ${BARNY_CONF}
		done

		# Ejecutamos ossim-agent
		ossim-agent_start
		popd 2>&- 1>&-
		;;
	stop)
		# for NET in ${INTERFACES}
		# do
		#	killall -9 snort_${NET}
		# done
		# killall -9 barnyard2
		# pkill -ef --signal 9 ossim-agent
		# rm -f /var/run/snort_*
		# rm -f /var/run/barnyard*
		# rm -f /var/run/ossim-agent.pid
		for NET in ${INTERFACES}
                do
			kill_process /var/run/snort_${NET}.pid snort_${NET}
			kill_process /var/run/barnyard2_${NET}.pid barnyard2
			rm /var/run/barnyard2_${NET}.pid
                done
		kill_process /var/run/ossim-agent.pid ossim-agent
		echo
		;;
	status)
		for NET in ${INTERFACES}
                do
			is_running /var/run/snort_${NET}.pid snort_${NET}
			is_running /var/run/barnyard2_${NET}.pid barnyard2_${NET}
                done
		is_running /var/run/ossim-agent.pid ossim-agent
		;;
esac
