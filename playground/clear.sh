#!/bin/bash

function clearImages(){
    TAG=$1

    if [ -z $TAG ]; then
        echo "Informe uma tag para exclusão"
        exit 1
    elif [[ $TAG != *"latest"* ]] && [[ $TAG != *"current"* ]]; then
        echo "APAGAR IMAGEM COM TAG [ $TAG ]"
        docker rmi --force $(docker images | grep $TAG | awk '{ print $3 }')
    else
        echo "Não é permitido apagar imagens com as tags 'latest' ou 'current'"
        exit 1
    fi
}