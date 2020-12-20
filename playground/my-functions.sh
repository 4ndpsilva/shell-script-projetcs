#!/bin/bash

function verifyAvailableSpace(){
  #Obtem espaço disponível na partição /ebs
  AVAILABLE_SPACE=$(df | awk '/ebs/ { print $4 }')

  #Converte de Gigabyte para Kilobyte
  REQUIRED_SPACE=$(($1 * 1024 * 1024))

  if [ $REQUIRED_SPACE -gt $AVAILABLE_SPACE ]; then
    echo "Espaço em disco insuficiente" >&2
    exit 1
  fi
}

function clearImage(){
  ENVIRONMENT=$1

  #Tag da imagem docker
  TAG=$2

  if [ ! -z $ENVIRONMENT ]; then
    EXIST_ENV=$(docker images | grep $ENVIRONMENT)
    
    if [ -z $EXIST_ENV ]; then
      echo "O ambiente informado não existe" >&2
      exit 1
    else
      if [ ! -z $TAG ]; then
        EXIST_TAG=$(docker images | grep $TAG)
      
        if [ -z $EXIST_TAG ]; then
          echo "A tag informada não existe" >&2
          exit 1
        else
          if [[ $TAG != *"latest"* ]] && [[ $TAG != *"current"* ]]; then
            echo "APAGAR IMAGEM COM A TAG [ $TAG ]"
            docker rmi --force $(docker images | grep $ENVIRONMENT | grep $TAG | awk '{ print $3 }')
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
}