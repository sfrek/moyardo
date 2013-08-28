#!/bin/bash
#
#
# script para borrar una máquina virtual

function usage(){
	local SCRIPT_NAME=${1}
	echo -e "\e[01;34mUso:\e[00m"
	cat << __EOF__
${SCRIPT_NAME} <domain>

Script encargado de eliminar completamente una máquina virtual, para ello:
1 - Busca y elimina los discos asociados
2 - Elimina la definicion de la máquina

__EOF__
}


function get_disks(){
	local DOMAIN=${1}
	virsh -q domblklist ${DOMAIN}
	return $?
}

[[ $# < 1 ]] && echo -e "\e[01;31mError\e[00m" && usage ${0} && exit 1

DOMAIN=${1}

get_disks ${DOMAIN}
