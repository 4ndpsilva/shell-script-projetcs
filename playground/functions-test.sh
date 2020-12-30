#!/bin/bash

NP=$#
USER=$(for i in $*; do :; done; echo "$i")

function checkParams(){
  # Quantidade total de parâmetros menos o primeiro (que é o nome do script)
  TOTAL_PARAMS=$(($# - 1))

  if [ "$NP" -lt "$TOTAL_PARAMS" ]; then
    USER=""
  fi

  # Quantidade de parâmetros obrigatórios
  NUM_REQUIRED_PARAMS=$(($TOTAL_PARAMS - 1))

  if [ ! "$NP" -ge "$NUM_REQUIRED_PARAMS" ]; then
    PARAMS=""

    for PARAM in $*; do
      if [ "$PARAM" != $1 ] && [ "$PARAM" != ${!#} ]; then
        PARAMS=$PARAMS""$PARAM" "
      fi
    done

    PARAMS=${PARAMS%?}

    if [ ${!#} != $1 ]; then
      OPTIONAL="(${!#})"
    fi

    echo "How to use: ./$1.sh $PARAMS $OPTIONAL"
    exit 1
  fi
}

function setBusyStatus(){
  if [ -z "$USER" ]; then
    echo "Executando $1. Iniciado em $(date). Aguarde..."
  else
    echo "Usuario: $USER. Executando $1. Iniciado em $(date). Aguarde..."
  fi
}