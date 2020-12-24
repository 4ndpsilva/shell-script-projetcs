#!/bin/bash

if [ "$#" -gt 2 ]; then
  echo "Apenas dois nomes são permitidos"
  echo "Tente de novo"
  exit 1
fi

if [ "$#" = 0 ]; then
  echo "Nenhum nome informado"
  exit 1
fi

NAME1=$1
NAME2=$2

if [ ! -z "$NAME1" ] && [ ! -z "$NAME2" ]; then
  echo "Nomes: $NAME1 - $NAME2"
else
  NAME1=$1
  echo "Nome: $NAME1" 
fi