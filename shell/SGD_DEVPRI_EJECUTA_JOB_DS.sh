#set -x
#!/bin/sh
###############################################
#                                             #
# Empresa: Altiuz                             #
#                                             #
###############################################

#DS81
EXE=/u/bin/s
INI=/u/data/sgd/SGDCONFG.INI
USER=`grep ^USUARIO_DS81 ${INI} | awk -F= '{print $2}'`
CT=`more /u/data/sgd/ds.cryp|awk '{print $1}'`
PASWD=`/u/bin/s/wcryp d $CT\c`
DIRECT=`grep ^DSHOME81 ${INI} | awk -F= '{print $2}'`
SERVER1=`grep ^SERVER1 ${INI} | awk -F= '{print $2}'`
SERVER2=`grep ^SERVER2 ${INI} | awk -F= '{print $2}'`
PROYECTO=`grep ^PROYECTO81 ${INI} | awk -F= '{print $2}'`
nRet=0


DIA_RESP=`date +"%d%m%Y"` 
DIA_EJEC=`date +"%d/%m/%Y %H:%M:%S"`

FECHA_PROC=`cut -c 17-24 /u/data/sgd/FEC_PRO.txt`


LOG=/u/data/sgd/log/
FILE_LOG=${LOG}SGD_DEVPRI_EJECUTA_JOB_DS.log

DIR_INPUT=/u/data/sgd/input/dev_primas/
FILE_ORIGINAL1=MDS_DATOS_CARTA_CLT_SGD


DIR_OUTPUT=/u/data/sgd/output/dev_primas/
FILES_CREADOS1=dev_prima_email.txt
FILES_CREADOS2=dev_prima_postal.txt
FILES_CREADOS3=dev_prima_rechazo.csv


rm -f ${FILE_LOG}

#####################################
# EJECUCION DE JOB DS CREDITOS      #
#####################################
cd $DIRECT/bin/

dsjob -domain $SERVER1:9080 -user $USER -password $PASWD -server $SERVER2 -run -mode NORMAL  -param Fecha_pro=$FECHA_PROC -jobstatus -warn UNLIMIT $PROYECTO Seq_job_devolucion_prima;nRet=$?
if [ "$nRet" == 1 -o "$nRet" == 2 ]; then
   DIA_TERM=`date +"%d/%m/%Y %H:%M:%S"`
   echo " El proceso se ejecuto correctamente con Status Code: $nRet" >> $FILE_LOG
   dsjob -jobinfo $PROYECTO Seq_job_devolucion_prima                  >> $FILE_LOG
   echo "Ejecución Finalizada : $DIA_TERM "                           >> $FILE_LOG
else
   DIA_TERM=`date +"%d/%m/%Y %H:%M:%S"`
   echo "Proceso ejecutado con errores Status Code: $nRet"            >> $FILE_LOG
   dsjob -jobinfo $PROYECTO Seq_job_devolucion_prima                  >> $FILE_LOG
   echo "Ejecución Finalizada  : $DIA_TERM "                          >> $FILE_LOG
  exit 99
fi

cd ${DIR_OUTPUT}
chmod 775 $FILES_CREADOS1
chmod 775 $FILES_CREADOS2
chmod 775 $FILES_CREADOS3


echo "Comienza cuadratura de registros de input versus los de salida ">>$FILE_LOG
############################################################################
#     Comienza cuadratura de registros de imput versus registros de output #
############################################################################

# Cuenta registros de Entrada
cd ${DIR_INPUT}
N_REG_INP1=`wc -l $FILE_ORIGINAL1 | awk '{printf("%01d\n",$1)}'`
T_REG_INP1=`expr $N_REG_INP1 - 2 `

Total_Input=$T_REG_INP1 
echo "Total de registros en archivos de entrada : $Total_Input" >> $FILE_LOG
FILLER1=`tail -1 ${DIR_INPUT}$FILE_ORIGINAL1`

#Cuenta registros de Salida   
cd ${DIR_OUTPUT}

N_REG_OUT1=`grep ^C $FILES_CREADOS1 | wc -l | awk '{printf("%01d\n",$1)}'`
N_REG_OUT2=`grep ^C $FILES_CREADOS2 | wc -l | awk '{printf("%01d\n",$1)}'`
N_REG_OUT3=`wc -l $FILES_CREADOS3 | awk '{printf("%01d\n",$1)}'`
N_REG_OUT3=`expr $N_REG_OUT3 - 1 `

Total_Output=`expr $N_REG_OUT1 + $N_REG_OUT2 + $N_REG_OUT3`
Total_Output_Raz=`expr $N_REG_OUT1 + $N_REG_OUT2`
echo "Total de registros en archivos de salida : $Total_Output" >> $FILE_LOG

#COMPARA CANTIDAD DE REGISTROS DE ARCHIVOS INPUT VERSUS OUTPUT
if [ "$Total_Input" == "$Total_Output" ] ; then
   echo "El total de registros Generados coinciden con los de entrada" >> ${FILE_LOG}
else
   echo "El total de registros Generados NO coinciden con los de entrada" >> ${FILE_LOG}
   exit 50
fi

##############################################################
# Revisa % de archivo sin_información                        #
##############################################################
RAZO_AVI=RAC_DEVOLUCION_PRIMAS
RAZO_INI=`grep ^$RAZO_AVI ${INI} | awk -F= '{print $2}'`
echo "Los n° a calcular son dev_prima_rechazo.csv * 100 /total de registros de todos los archivos es  : $N_REG_OUT3 $Total_Output" >> ${FILE_LOG}
RAZO_CALC=`expr $Total_Output_Raz \* 100 / $Total_Input`
if [ $RAZO_CALC -lt $RAZO_INI ]; then
   echo "Error No cumple con Porcentaje de Razonabilidad Minimo : " $RAZO_INI " Calculado : " $RAZO_CALC  >> ${FILE_LOG}
   exit 50			
else
   echo " OK Se cumple con Porcentaje de Razonabilidad Minimo" >> ${FILE_LOG}
fi



cd ${DIR_OUTPUT}
##############################################################
# Obtiene Header y crea nuevo archivo con Header obtenido    #
##############################################################
N_REG_OUT1=`grep ^C $FILES_CREADOS1 | wc -l | awk '{printf("%010d\n",$1)}'`
N_REG_OUT2=`grep ^C $FILES_CREADOS2 | wc -l | awk '{printf("%010d\n",$1)}'`


REG_OUT1=`wc -l $FILES_CREADOS1 | awk '{printf("%010d\n",$1)}'`
REG_OUT2=`wc -l $FILES_CREADOS2 | awk '{printf("%010d\n",$1)}'`

UNO=1
SECUENCIA=`echo $UNO | awk '{ printf("%-292s",$0)}'`


echo "KDPR"$DIA_EJEC$REG_OUT1$N_REG_OUT1$SECUENCIA"                                                                                                                                                                                                                                                                                    " > $FILES_CREADOS1.tmp1
cat $FILES_CREADOS1.tmp1 $FILES_CREADOS1 > $FILES_CREADOS1.tmp2
rm -f $FILES_CREADOS1.tmp1
mv $FILES_CREADOS1.tmp2 $FILES_CREADOS1

echo "KDRP"$DIA_EJEC$REG_OUT2$N_REG_OUT2$SECUENCIA"                                                                                                                                                                                                                                                                                    " > $FILES_CREADOS2.tmp1
cat $FILES_CREADOS2.tmp1 $FILES_CREADOS2 > $FILES_CREADOS2.tmp2
rm -f $FILES_CREADOS2.tmp1
mv $FILES_CREADOS2.tmp2 $FILES_CREADOS2


chmod  775 $FILES_CREADOS1
chmod  775 $FILES_CREADOS2

compress -f $FILES_CREADOS1
compress -f $FILES_CREADOS2

exit 0
