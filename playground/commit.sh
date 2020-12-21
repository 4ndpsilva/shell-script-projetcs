#!/bin/bash
#=============================================================
#
#        FILE: .../docker-imgs/commit.sh
#
#       USAGE: commit.sh
#              $1 -> TAG
#
# DESCRIPTION: Commit Database Docker Image
#
#=============================================================
#
# Uncomment to print commands and their arguments as they are executed (this is the debug mode)
#set -x
#
# Exit immediately if a command exits with a non-zero status
set -e
source ./functions.sh


checkParams "commit"


# colocando todas as variáveis de .env no AMBIENTE
setEnvVars


# Não permite execução se TAG passada já existe
existentTag=$(docker images | grep $LOCAL_IMAGE | grep \\s$1\\s || echo "")
if [ ! -z "$existentTag"  ]; then
  echo "Erro: Tag $1 já existe!" 1>&2
  exit 1
fi


setBusyStatus "COMMIT"

LOGFILE=logs/commit.log

# variável de controle, usada para analisar mais pra frente se a atual imagem "latest" fica sem TAG
oldHash=$(docker images | grep -F ${LOCAL_IMAGE} | grep latest | awk '{print $3}')

echo "===============================================================" >> $LOGFILE
date >> $LOGFILE
echo "Parando serviço..." >> $LOGFILE
docker stop $CONTAINER >> $LOGFILE


echo "Salvando estado..." >> $LOGFILE
docker commit $CONTAINER $LOCAL_IMAGE:latest >> $LOGFILE
if [ ! -z "$1" ]; then
  TAG=$1
  docker tag $LOCAL_IMAGE:latest $LOCAL_IMAGE:$TAG >> $LOGFILE
fi

echo "Reiniciando serviço..." >> $LOGFILE
docker start $CONTAINER >> $LOGFILE


# Se a imagem que estava marcada como latest nao tiver mais nenhuma TAG, apaga
clearImageIfNeeded $oldHash

newHash=$(docker images | grep -F ${LOCAL_IMAGE} | grep latest | awk '{print $3}')
echo "Nova imagem: $newHash" >> $LOGFILE

echo "Imagem de Banco de Dados salva!" >> $LOGFILE

setIdleStatus

echo "Ok, my friend!"
