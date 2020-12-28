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

if [ -z "$IMAGE_ENV" ] || [ "$IMAGE_ENV" = "NONE" ]; then
  echo "É necessário informar um ambiente" >&2
  exit 1
fi

EXIST_IMAGE_ENV=$(docker images | grep -w $IMAGE_ENV | awk '{ print $1 }' | sed -n 1p)

if [ -z "$EXIST_IMAGE_ENV" ]; then
  echo "O ambiente informado não existe" >&2
  exit 1
fi

if [ -z "$TAG" ] || [ "$TAG" = "NONE" ]; then
  echo "É necessário informar uma tag" >&2
  exit 1
fi

EXIST_TAG=$(docker images | grep -w $IMAGE_ENV | grep -w $TAG | awk '{ print $2 }' | sed -n 1p)

if [ -z "$EXIST_TAG" ]; then
  echo "A tag informada não existe" >&2
  exit 1
fi

if [[ "$TAG" = *"latest"* ]] || [[ "$TAG" = *"current"* ]]; then
  echo "Não é permitido apagar imagens com as tags 'latest' ou 'current'" >&2
  exit 1
fi

docker rmi -f $(docker images | grep -w $IMAGE_ENV | grep -w $TAG | awk '{ print $3 }') >> $LOGFILE
echo "Imagem excluída com sucesso" >> $LOGFILE

#setIdleStatus