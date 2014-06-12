#set -x
#!/bin/sh
#############################################
#                                           #
# Empresa: FACTORIT                         #
#                                           #
#############################################


FECHA_PROC=`cut -c 17-24 /u/data/sgd/FEC_PRO.txt`

LOG=/u/data/sgd/log/
FILE_LOG=${LOG}SGD_MAILING_RESPALDA.log

rm -f ${FILE_LOG}

echo "comienza  bkp  archivos de Entrada" >> $FILE_LOG
#############################################
# Realiza Back up                           #
#############################################
DIR_INPUT=/u/data/internet/INF_PROG1

FILE_INPUT1=INF_PROG1


mv $DIR_INPUT$FILE_INPUT1 ${DIR_INPUT}bkp/$FILE_INPUT1.$FECHA_PROC


compress -f ${DIR_INPUT}bkp/$FILE_INPUT1.$FECHA_PROC


echo "comienza  bkp  archivos de Salida" >> $FILE_LOG
#############################################
# Realiza Back up                           #
#############################################
DIR_OUTPUT=/u/data/sgd/output/mailing/

FILE_OUTPUT1=MovNoFact_email.txt



mv $DIR_OUTPUT$FILE_OUTPUT1.Z ${DIR_OUTPUT}bkp/$FILE_OUTPUT1.$FECHA_PROC.Z



compress -f ${DIR_OUTPUT}bkp/$FILE_OUTPUT3.$FECHA_PROC



echo "termina  bkp  archivos" >>  $FILE_LOG 

exit 0

