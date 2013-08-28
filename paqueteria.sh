#!/bin/bash
# 
# Descripción: Script para crear una página sencilla que muestre el numero de paquetes a actualizar.
#              que llevan sin cambiar la contraseña.
#
# Autor:       Pedro Jiménez Solís <pjimenez@abadasoft.com>
# 
# Versión:     1.07
#
# Changelog: 
#            1.07: Cambios en el bucle para automatizar la "Version y Paquetes".
#            1.06: Se añade versión de Kernel a la información extraída.
#            1.05: Cambio al formato nuevo:
#                                           Nombre del Servidor 	Versión 	Paquetes desactualizados 	Uptime
#            1.04: Ajustes Varios.
#            1.03: Añadido formato para "BootStrap" y la generación tan solo de la fila correspondiente, no de la tabla.

# ---------
# Variables
# ---------
FICHERO_SALIDA="/tmp/paqueteria_sistema.html";
HOSTNAME=$(hostname);
COLORFONDO="GREEN"
USUARIO="root"
VERSION="Unknown";
VERSION_REDHAT="/etc/redhat-release"
VERSION_DEBIAN="/etc/debian_version"
VERSION_UBUNTU="/etc/lsb-release"

# ---------------------------------------
# Creacion de Fichero de salida para HTML
# ---------------------------------------
if [ ! -f $FICHERO_SALIDA ]; then
  touch $FICHERO_SALIDA
else
  > $FICHERO_SALIDA
fi

# ------------------------------------------------
# Bucle Principal (incluye la generacion del html)
# 
# ------------------------------------------------

if [ -f $VERSION_REDHAT ]; then
   VERSION="$(cat $VERSION_REDHAT)";
   PAQUETES=$(yum check-update | grep -E "x86|i386" | wc -l);
elif [ -f $VERSION_UBUNTU ]; then
   VERSION="$(cat /etc/lsb-release | grep DESCRIPTION | cut -d"\"" -f 2)";
   PAQUETES=$(apt-get dist-upgrade -Vs | grep "^ " | wc -l);
elif [ -f $VERSION_DEBIAN ]; then
   VERSION="Debian $(cat $VERSION_DEBIAN)";
   PAQUETES=$(apt-get dist-upgrade -Vs | grep "^ " | wc -l);
fi

if [ $PAQUETES -gt 0  ]; then
    COLORFONDO="RED"
fi

UPTIME=$(uptime | cut -d"," -f 1 | cut -c11-20);
KERNEL="$(uname -r)";

echo "<tr> <td><b>$HOSTNAME</b></td> <td>$VERSION</td> <td>$KERNEL</td> <td STYLE=\"color:$COLORFONDO;\">$PAQUETES</td> <td>$UPTIME</td> </tr>" >> $FICHERO_SALIDA

chown $USUARIO:$USUARIO $FICHERO_SALIDA
