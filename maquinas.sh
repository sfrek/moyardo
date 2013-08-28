#!/bin/bash
# script para ver las máquinas virtuales
# virsh -q list -> lista las máquinas virtuales activas
# virsh -q list --all -> lista todas las máquinas virtuales

usage() {
cat << EOF
Muestra las Máquinas virtuales que residen en ${HOSTNAME}

Modo de ejecución:
$0 [-h] [-a] [-p <patrón>]

Esplicación:
	-h	Muestra esta ayuda
	-p	Patrón, muestra aquellas máquinas que conincida con <patrón>
	-a	"all", comprueba y/o muestra según <patrón> también las no activas.
	La salida del comando con -a no informa del estado ( runnig vs stoped ).
	
EOF
}

VIRSH="virsh -q list"

while getopts "p:ah" OPTION;do
	case $OPTION in
		p)
			PATTERN=${OPTARG}
			;;
		a)
			VIRSH=${VIRSH}" --all"
			;;
		h)
			usage
			exit 0
			;;
		*)
			usage
			exit 1
			;;
 	esac
done

# [ -z ${PATTERN} ] && exec ${VIRSH} || exec ${VIRSH} | grep ${PATTERN} | cut -d' ' -f2
# " 5     openstorm-diablo-compute01     running" 
# "espacioNumeroEspaciox([5|6])MáquinaTabulador.... pufff mejor:
exec ${VIRSH} | awk '/'${PATTERN}'/ {print $2}'
