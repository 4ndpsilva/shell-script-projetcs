#!/bin/bash

#=======================================================================
#
#        FILE: .../docker-db/clearDockerImages.sh
#
#       USAGE: clearDockerImages.sh ENV TAG
#              $1 -> ENV - Environment Local or Remote
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


checkParams "clearDockerImages"

setBusyStatus "CLEAR"


#Ambiente
ENVIRONMENT=$1

#Tag da imagem docker
TAG=$2

if [ ! -z $ENVIRONMENT ]; then
  EXIST_ENV=$(docker images | grep -w $ENVIRONMENT | awk '{ print $1 }' | sed -n 1p)

  if [ -z $EXIST_ENV ]; then
    echo "O ambiente informado não existe" >&2
    exit 1
  else
    if [ ! -z $TAG ]; then
      EXIST_TAG=$(docker images | grep -w $ENVIRONMENT | grep -w $TAG | awk '{ print $2 }' | sed -n 1p)

    if [ -z $EXIST_TAG ]; then
      echo "A tag informada não existe" >&2
      exit 1
    else
	    if [[ $TAG != *"latest"* ]] && [[ $TAG != *"current"* ]]; then
        docker rmi -f $(docker images | grep -w $ENVIRONMENT | grep -w $TAG | awk '{ print $3 }')
        echo "Imagem [ $TAG ] excluída com sucesso" >&1
        exit 0
      else
        echo "Não é permitido apagar imagens com as tags 'latest' ou 'current'" >&2
        exit 1
      fi
    fi
    else
      echo "É necessário informar uma tag" >&2
      exit 1
    fi
  fi
else
  echo "É necessário informar um ambiente" >&2
  exit 1
fi