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
proyecto=`grep ^PROYECTO ${INI} | awk -F= '{print $2}'`
## Setea directorio
cd /IBM/InformationServer/Server/DSEngine/
. ./dsenv

echo "Proceso:" $sequencer > $archlog
echo "============================================================" >> $archlog
echo "Proceso Ejecutado el dia `date '+%Y-%m-%d %H:%M:%S'`" >> $archlog

## Ejecucion
$datashome/dsjob -run -mode NORMAL -wait -jobstatus $proyecto $sequencer
## Status Code de la ejecucion del Sequencer
run_stat=$?
echo "Status Code (run_stat): "$run_stat >> $archlog
$datashome/dsjob -jobinfo $proyecto $sequencer >> $archlog


