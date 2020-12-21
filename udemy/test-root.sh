#!/bin/bash

#######################################################
#                                                     #
# Testar usuário é root                               #
#                                                     #
#######################################################

#Testar se o usuário tem permissão de root
if [[ ${UID} -eq 0 ]]; then
  echo "Você tem permissão de ROOT"
  echo "Você quer parar o servidor Apache?"
  echo "Digite (s) para Sim ou (n) para Não"
  read OP
  
  if [[ ${OP} = "S" || ${OP} = "s" ]]; then
    echo "PARAR O SERVIDOR APACHE"
    echo "Parando o servidor"
    systemctl stop apache2
  else
    echo "Nada a fazer"
  fi
else
  echo "Vire ROOT para usar esse programa"
fi