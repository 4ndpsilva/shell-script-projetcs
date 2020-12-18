#!/bin/bash
#=============================================================
#
#        FILE: .../docker-imgs/pull.sh
#
#       USAGE: pull.sh TAG
#              $1 -> TAG
#
# DESCRIPTION: Get Database Docker Container from AWS ECR repository
#
#=============================================================
#
# Uncomment to print commands and their arguments as they are executed (this is the debug mode)
#set -x
#
# Exit immediately if a command exits with a non-zero status
set -e
source ./functions.sh

checkParams "pull"

# colocando todas as variáveis de .env no AMBIENTE
setEnvVars $1

setBusyStatus "PULL"

LOGFILE=logs/pull.log

echo "===================================================" >> $LOGFILE
date >> $LOGFILE

oldCurrentHash=$(docker images | grep ${LOCAL_IMAGE} | grep current | awk '{print $3}')
oldLatestHash=$(docker images | grep ${LOCAL_IMAGE} | grep latest | awk '{print $3}')




# PULL
echo "Fazendo login docker no ECR da AWS..." >> $LOGFILE
$(aws ecr get-login --no-include-email) >> $LOGFILE 2>/dev/null


echo "PULL!" >> $LOGFILE
docker pull ${ECR_IMAGE}:${VERSION} >> $LOGFILE






echo "Mundando referência de imagem de banco de dados atual..." >> $LOGFILE
docker tag ${ECR_IMAGE}:${VERSION} ${LOCAL_IMAGE}:current > /dev/null
docker tag ${ECR_IMAGE}:${VERSION} ${LOCAL_IMAGE}:latest > /dev/null


echo "Parando serviço..." >> $LOGFILE
docker stop $CONTAINER

echo "Removendo serviço..." >> $LOGFILE
docker rm $CONTAINER

echo "Reiniciando serviço do ponto previmente salvo..." >> $LOGFILE
docker-compose up -d current

clearImageIfNeeded $oldCurrentHash
clearImageIfNeeded $oldLatestHash

postRun $CONTAINER >> $LOGFILE

echo "Serviço restaurado!" >> $LOGFILE

setIdleStatus
