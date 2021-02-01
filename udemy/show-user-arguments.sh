#!/bin/bash

NAME1=$1
NAME2=$2

if [ "$#" -gt 2 ]; then
  echo "Apenas dois nomes são permitidos"
  echo "Tente de novo"
  exit 1
fi

if [ "$#" = 0 ]; then
  echo "Nenhum nome informado"
  exit 1
fi


if [ ! -z "$NAME1" ] && [ ! -z "$NAME2" ]; then
  echo "Nomes: $NAME1 - $NAME2"
else
  echo "Nome: $NAME1" 
fi