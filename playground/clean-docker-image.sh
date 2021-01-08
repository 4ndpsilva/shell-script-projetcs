#!/bin/bash

#=======================================================================
#
#        FILE: .../docker-db/clean-docker-image.sh
#
#       USAGE: clearDockerImages.sh ENV TAG
#              $1 -> IMAGE - Local or Remote image (AWS ECR repository)
#              $2 -> TAG
# DESCRIPTION: Clear database docker image local or from AWS ECR repository
#
#=======================================================================
#
# Uncomment to print commands and their arguments as they are executed (this is the debug mode)
#set -x
#
# Exit immediately if a command exits with a non-zero status
set -e

source ./functions.sh


checkParams "clean-docker-image" "IMAGE" "TAG" "USER"

setBusyStatus "CLEAN"

LOG_DIR="logs"
LOGFILE="$LOG_DIR/clean-docker-image.log."$(date +%Y%m%d)
LOG_PREFIX="[$(date '+%F %T')]"

echo "===================================================" >> $LOGFILE

#Variável usada para representar se é uma imagem Local ou Remota (ECR)
IMAGE=$1

#Tag da imagem docker
TAG=$2


if [ "${IMAGE^^}" = "LOCAL" ]; then
  IMAGE="local/database"
elif [ "${IMAGE^^}" = "REMOTO" ]; then
  IMAGE="536311044217.dkr.ecr.us-east-1.amazonaws.com/c6bank/database"
fi

EXIST_IMAGE=$(docker images | grep -wF $IMAGE | awk '{ print $1 }' | sed -n 1p)

if [ -z "$EXIST_IMAGE" ]; then
  echo "$LOG_PREFIX [ERROR   ] A imagem ${IMAGE} não existe" >&2
  exit 1
fi

EXIST_TAG=$(docker images | grep -wF $IMAGE | grep -wF $TAG | awk '{ print $2 }' | sed -n 1p)

if [ -z "$EXIST_TAG" ]; then
  echo "$LOG_PREFIX [ERROR   ] A tag ${TAG} não existe" >&2
  exit 1
fi

if [[ "$TAG" = *"latest"* ]] || [[ "$TAG" = *"current"* ]]; then
  echo "$LOG_PREFIX [ERROR   ] Não é permitido remover imagens com as tags 'latest' ou 'current'" >&2
  exit 1
fi

IMAGE_ID=$(docker images | grep -wF $IMAGE | grep -wF $TAG | awk '{ print $3 }')
docker rmi -f $IMAGE_ID >> $LOGFILE

echo "" >> $LOGFILE
echo "$LOG_PREFIX [INFO   ] Imagem removida com sucesso" >> $LOGFILE
echo "" >> $LOGFILE

setIdleStatus