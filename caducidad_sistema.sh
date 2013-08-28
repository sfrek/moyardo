#!/bin/bash
# 
# Descripción: Script para crear una página sencilla que muestre los usuarios del sistema y el numero de dias
#              que llevan sin cambiar la contraseña.
#
# Autor:       Pedro Jiménez Solís <pjimenez@abadasoft.com>
# 
# Versión:     1.0

# ---------
# Variables
# ---------
DIASTOTALES="0";
UMBRAL_CADUCIDAD="180";
FICHERO_SALIDA="/tmp/cuentas_sistema.html";
HOSTNAME=$(hostname);
LISTA_USUARIOS="root"

# ---------
# Funciones
# ---------
# Solo en RedHat se especifica: #function 
cuantos_dias () {
# 
# Descripcion: Recibe una fecha en formato salida de "passwd -S"
#
#                    passwd -S pjimenez ==> pjimenez P 05/03/2011 0 99999 7 -1
#
#              y la convertimos a formato "date" para calcular el
#              nº de segs de diferencia (despues los dias) con respecto
#              a la fecha actual.
#              date --date='2000-01-01 00:00:01' +%s ==> # 946684800

YEAR=$(echo $1 | cut -c7-10);
MONTH=$(echo $1 | cut -c4-5);
DAY=$(echo $1 | cut -c1-2);
HOUR="00";
MINUTE="00";
SEC="01";
# ------------------------------------------------------------
# Sistemas RedHat:
# FECHAFINAL="$YEAR-$MONTH-$DAY $HOUR:$MINUTE:$SEC UTC"

# Sistemas Debian:
FECHAFINAL="$YEAR-$DAY-$MONTH $HOUR:$MINUTE:$SEC"
# ------------------------------------------------------------
DIASTOTALES=$(date --date="$FECHAFINAL" +%s);
AHORA=$(date +%s)
DIASTOTALES=$(expr $AHORA - $DIASTOTALES;) # Diferencia en Segundos entre las fechas.
DIASTOTALES=$(expr $DIASTOTALES / 60); # Minutos
DIASTOTALES=$(expr $DIASTOTALES / 60); # Horas
DIASTOTALES=$(expr $DIASTOTALES / 24); # Dias   
return  $DIASTOTALES;
}

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
# ------------------------------------------------

#echo "<IMG SRC=logo_dpto_sistemas.png BORDER=1 VSPACE=1 HSPACE=170>" > $FICHERO_SALIDA
echo "<TABLE ALIGN=\"center\" BORDER=\"1\">" >> $FICHERO_SALIDA
echo "<TR><TD STYLE=\"background-color:yellow;font-size:18pt\" COLSPAN=\"3\" ALIGN=\"center\"><b><u>$HOSTNAME</u></b></TD></TR>" >> $FICHERO_SALIDA
echo "<TR STYLE=\"background-color:lightgray;\"><TD ALIGN=\"center\"><u>Usuario</u></TD> <TD ALIGN=\"center\" BGCOLOR=\"$COLORFONDO\"><u>Ultimo Cambio</u></TD> <TD ALIGN=\"center\" BGCOLOR=$COLORFONDO><u>Numero Dias</u></TD> </TR>" >> $FICHERO_SALIDA

#for usuario in `cat /etc/passwd | grep 100 | grep -v "100:" | cut -d ":" -f 1`; do 
# Solo tenemos a ROOT:
for usuario in $LISTA_USUARIOS; do 
   caducidad=$(passwd -S $usuario | cut -d " " -f 3 );
   
   cuantos_dias $caducidad;
   numero_dias=$?;
   if [ $numero_dias -ge $UMBRAL_CADUCIDAD ]; then 
     COLORFONDO="red";
     # ---------------
     # Envio de correo
     # ---------------
     ENVIOCORREO=1;
   else 
     COLORFONDO="white"
   fi
      
   #echo "U: $usuario C: $caducidad" D: $numero_dias ;
   echo "<TR> <TD ALIGN=\"center\">$usuario</TD> <TD ALIGN=\"center\" BGCOLOR=\"$COLORFONDO\">$caducidad</TD> <TD ALIGN=\"center\" BGCOLOR=$COLORFONDO>$numero_dias</TD> </TR>" >> $FICHERO_SALIDA


done
echo "</TABLE\>" >> $FICHERO_SALIDA
#chown sistemas.hf:sistemas.hf $FICHERO_SALIDA;

