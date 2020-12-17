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

#Verifica espaço disponível na partição ou disco
FREE_SPACE=$(getPartitionFreeSpace)

#Captura o valor numérico do espaço
QUANTITY=$(echo $FREE_SPACE | grep -Eo "[[:digit:]]+")

#Captura a letra inicial que representa a unidade de grandeza (G - Gigabyte, M - Megabyte, K - Kilobyte)
TYPE=$(echo $FREE_SPACE | grep -Eo "*[K|M|G|k|m|g]")

if [ -n $FREE_SPACE ]; then
  if [ $QUANTITY -le 100 ]; then
    echo "Espaço Livre = $FREE_SPACE"
    echo "Quantidade: $QUANTITY"
    echo "Grandeza: $TYPE"

    if [ $TYPE = "G" ]; then
      if [ $QUANTITY -le 100 ]; then
        echo "Espaço em disco insuficiente" >&2
        exit 1
      fi
    fi

    # Rotina para liberar espaço - apagar imagens containers não utilizados
    docker system prune --all
  fi
fi

echo "CONTINUAR EXECUÇÃO"
exit 1

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