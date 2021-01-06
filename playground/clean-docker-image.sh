#!/bin/bash

#=======================================================================
#
#        FILE: .../docker-db/clean-docker-image.sh
#
#       USAGE: clearDockerImages.sh ENV TAG
#              $1 -> IMAGE_ENV - Image Local or Remote (AWS ECR repository)
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

#source ./functions.sh


#checkParams "clean-docker-image"

#setBusyStatus "CLEAR"

LOGFILE=clean-docker-image.log

echo "===================================================" >> $LOGFILE
date >> $LOGFILE

#Variável usada para representar se é uma imagem ECR ou local
IMAGE_ENV=$1

#Tag da imagem docker
TAG=$2


if [ "$IMAGE_ENV" = "Local" ]; then
  #IMAGE_ENV="local/database"
  IMAGE_ENV="python"
elif [ "$IMAGE_ENV" = "Remoto" ]; then
  #IMAGE_ENV="536311044217.dkr.ecr.us-east-1.amazonaws.com/c6bank/database"
  IMAGE_ENV="mongo"
fi

EXIST_IMAGE_ENV=$(docker images | grep -wF $IMAGE_ENV | awk '{ print $1 }' | sed -n 1p)

if [ -z "$EXIST_IMAGE_ENV" ]; then
  echo "A imagem ${IMAGE_ENV} não existe" >&2
  exit 1
fi

EXIST_TAG=$(docker images | grep -wF $IMAGE_ENV | grep -wF $TAG | awk '{ print $2 }' | sed -n 1p)

if [ -z "$EXIST_TAG" ]; then
  echo "A tag ${TAG} não existe" >&2
  exit 1
fi

if [[ "$TAG" = *"latest"* ]] || [[ "$TAG" = *"current"* ]]; then
  echo "Não é permitido remover imagens com as tags 'latest' ou 'current'" >&2
  exit 1
fi

IMAGE_ID=$(docker images | grep -wF $IMAGE_ENV | grep -wF $TAG | awk '{ print $3 }')
docker rmi -f $IMAGE_ID >> $LOGFILE

echo "" >> $LOGFILE
echo "Imagem removida com sucesso" >> $LOGFILE
echo "" >> $LOGFILE

#setIdleStatus