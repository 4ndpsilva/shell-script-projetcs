#!/bin/bash

echo "Digite -1 para sair ou outro valor para continuar" 
read op

while [ $op != "-1" ]; do
  echo "Digite o nome do arquivo ou diretório: " 
  read name

  if [ -e "$name" ]; then
  echo "$name EXISTE"

  if [ -d "$name" ]; then 
    echo "$name é um diretório"
  elif [ -f "$name" ]; then
    echo "$name é um arquivo"
  fi  
  else
    echo "$name NÃO EXISTE"    
  fi

  echo "Para sair digite -1 ou outro valor para continuar" 
  read op
done