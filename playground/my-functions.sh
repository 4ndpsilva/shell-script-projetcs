#!/bin/bash

function verifyAvailableSpace(){
  #Obtem espaço disponível na partição /ebs
  AVAILABLE_SPACE=$(df | awk '/ebs/ { print $4 }')

  #Converte de Gigabyte para Kilobyte
  REQUIRED_SPACE=$(expr $(($1 * 1024 * 1024)))

  if [ $REQUIRED_SPACE -gt $AVAILABLE_SPACE ]; then
    echo "Espaço em disco insuficiente" >&2
    exit 1
  fi
}

function clearImage(){
  #Tag de imagem docker
  TAG=$1
  #Ambiente - Local ou Remoto
  ENV=$2

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
}