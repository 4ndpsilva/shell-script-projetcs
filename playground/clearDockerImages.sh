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

#Ambiente - Local ou Remoto
ENV=$1

#Tag de imagem docker
TAG=$2

if [ ! -z $ENV ]; then
    if [ -z $TAG ]; then
        echo "É necessário informar uma tag para exclusão" >&2
        exit 1
    elif [[ $TAG != *"latest"* ]] && [[ $TAG != *"current"* ]]; then
        echo "APAGAR IMAGEM COM A TAG [ $TAG ]"
        docker rmi --force $(docker images | grep $TAG | awk '{ print $3 }')
    else
        echo "Não é permitido apagar imagens com as tags 'latest' ou 'current'" >&2
        exit 1
    fi
else
    echo "É necessário informar um ambiente de execução" >&2
    exit 1
fi