#!/bin/sh
################################################################################
## Shell ejecuta Job DataStage                                                ##
## Uso:                                                                       ##
## Ejecuta JOB desde Malla Control-M                                          ##
################################################################################
##============================================================================##
################################################################################
## Parametros:                                                                ##
##																	          ##
## $3: Nombre Sequencer                                                       ##
##                             												  ##
################################################################################
##============================================================================##
################################################################################
## Solicitado por:                                                            ##
##      Banco Chile                                                           ##
## Elaborado por:                                                             ##
##      FACTORIT                                                              ##
## Fecha de Creacion:                                                         ##
##      2011-05-20                                                            ##
## Version:                                                                   ##
##      1.0   RMY                                                             ##
##      1.1   RMY - Agrega variable severidad                                 ##
##      1.2   RMY - Agrega validacion de caida por severidad                  ##
################################################################################
##============================================================================##
# Seteo de Variables
INI=/u/data/sgd/SGDCONFG.INI
sequencer=SEQ_SGD_MAILING_INF_PROG1_CCA
archlog=/u/ulog/$sequencer.out
datashome=/IBM/InformationServer/Server/DSEngine/bin
arch_conf_Sev="/u/data/CDW/ConfigSev.txt"
arch_final=/u/data/SGD/output/mailing/MovNoFact.txt
arch_resp=/u/data/SGD/output/mailing/MovNoFact_email.txt
proyecto=`grep ^PROYECTO ${INI} | awk -F= '{print $2}'`
NomProceso=INF_PROG1_CCA
## Setea directorio
cd /IBM/InformationServer/Server/DSEngine/
. ./dsenv

echo "Proceso:" $sequencer > $archlog
echo "============================================================" >> $archlog
echo "Proceso Ejecutado el dia `date '+%Y-%m-%d %H:%M:%S'`" >> $archlog

## Ejecucion
$datashome/dsjob -run -mode NORMAL -wait -jobstatus $proyecto $sequencer;nRet=$?

if [ "$nRet" == 1 -o "$nRet" == 2 ]; then
   DIA_TERM=`date +"%d/%m/%Y %H:%M:%S"`
   echo " El proceso se ejecuto correctamente con Status Code: $nRet" >> $FILE_LOG
   dsjob -jobinfo $PROYECTO $SEQUENCER                                >> $FILE_LOG
   echo "Ejecución Finalizada : $DIA_TERM "                           >> $FILE_LOG
   cp $arch_final $arch_resp
   compress $arch_resp
	cd /u/data/SGD/tmp/DataSets
	rm -rf $NomProceso*
	cd /u/data/SGD/tmp/DataSets/Node01
	rm -rf $NomProceso*
   exit 0
else
   DIA_TERM=`date +"%d/%m/%Y %H:%M:%S"`
   echo "Proceso ejecutado con errores Status Code: $nRet"            >> $FILE_LOG
   dsjob -jobinfo $PROYECTO $SEQUENCER                                >> $FILE_LOG
   echo "Ejecución Finalizada  : $DIA_TERM "                          >> $FILE_LOG
   cd /u/data/SGD/tmp/DataSets
	rm -rf $NomProceso*
	cd /u/data/SGD/tmp/DataSets/Node01
  rm -rf $NomProceso*
   exit 99
fi

############################################################################
if [ "$?" = "0" ]; then
cp $arch_final $arch_resp
compress $arch_resp
      exit 0
else
        exit 99
fi


## Status Code de la ejecucion del Sequencer
run_stat=$?
echo "Status Code (run_stat): "$run_stat >> $archlog
$datashome/dsjob -jobinfo $proyecto $sequencer >> $archlog
