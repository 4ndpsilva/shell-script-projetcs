#!/bin/bash
#=============================================================
#
#        FILE: .../docker-imgs/push.sh
#
#       USAGE: push.sh TAG
#              $1 -> TAG
#
# DESCRIPTION: Save Database Docker Container and Push to AWS ECR repository
#
#=============================================================
#
# Uncomment to print commands and their arguments as they are executed (this is the debug mode)
#set -x
#
# Exit immediately if a command exits with a non-zero status
set -e
source ./functions.sh


checkParams "push"


setBusyStatus "PUSH"

# colocando todas as variáveis de .env no AMBIENTE
setEnvVars $1
CONNECTION_MTR=sys/gudiao@localhost:1522/MTR
CONNECTION_CDB=sys/gudiao@localhost:1522/ORCLCDB
LOGFILE=logs/push.log


# iniciando logs
echo "===================================================" >> $LOGFILE
date >> $LOGFILE



# muda porta
echo "Alterando porta do serviço de Banco de Dados para 1522..." >> $LOGFILE
changeCP 1521 1522 >> $LOGFILE


# espera healthy state
waitForHealthy $CONTAINER >> $LOGFILE
sleep 60s # mais um minutinho que garante o funcionamento saudavel do banco de dados

# obtendo atuais ids das imagens locais
oldCurrentHash=$(docker images | grep -F $LOCAL_IMAGE | grep current | awk '{print $3}')
oldLatestHash=$(docker images | grep -F $LOCAL_IMAGE | grep latest | awk '{print $3}')

# rodar script orclcdb-settings
#echo "Acertando tamanho de arquivo de UNDO..." >> $LOGFILE
#sqlplus -s $CONNECTION_CDB as sysdba @sql/orclcdb-settings.sql >> $LOGFILE
#if [ -f "change.sql" ]; then
#  echo "Removendo arquivo change.sql criado temporariamente..." >> $LOGFILE
#  rm -rf change.sql
#fi
#echo "" >> $LOGFILE

# rodar script mtr-settings
echo "Acertando arquivos TEMP e SDIMIO.DATA..." >> $LOGFILE
sqlplus -s $CONNECTION_MTR as sysdba @sql/mtr-settings.sql >> $LOGFILE
echo "" >> $LOGFILE


echo "Parando serviço para commit..." >> $LOGFILE
docker stop $CONTAINER >> $LOGFILE


echo "Commit do estado atual do banco de dados..." >> $LOGFILE
docker commit $CONTAINER temp:latest >> $LOGFILE


echo "Removendo atual container do banco de dados..." >> $LOGFILE
docker rm $CONTAINER >> $LOGFILE



echo "Reiniciando serviço do ponto previmente salvo..." >> $LOGFILE
docker-compose up -d newversion >> $LOGFILE


echo "Fazendo limpezas..." >> $LOGFILE
docker rmi -f temp:latest >> $LOGFILE

docker tag ${ECR_IMAGE}:${VERSION} $LOCAL_IMAGE:current > /dev/null
docker tag ${ECR_IMAGE}:${VERSION} $LOCAL_IMAGE:latest > /dev/null

clearImageIfNeeded $oldCurrentHash
clearImageIfNeeded $oldLatestHash

docker image prune -f >> $LOGFILE
docker container prune -f >> $LOGFILE



echo "Fazendo login docker no ECR da AWS..." >> $LOGFILE
$(aws ecr get-login --no-include-email) >> $LOGFILE 2>/dev/null


echo "PUSH!" >> $LOGFILE
docker push ${ECR_IMAGE}:${VERSION} >> $LOGFILE


echo "Imagem salva no ECR e serviço restaurado!" >> $LOGFILE

setIdleStatus

echo "Ok, my friend!"
