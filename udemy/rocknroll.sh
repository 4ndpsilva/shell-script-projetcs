#!/bin/bash

#######################################################
#                                                     #
# Script para testar comandos confdicionais (IF/ELSE) #
#                                                     #
#######################################################

#Checar idade do usuário
echo "BEM VINDO AS NOSSO PROGRAMA $0"

#Colatar a resposta do usuário
echo "Qualk sua idade?"
read IDADE

#Condicionais com IF
if [[ ${IDADE} -ge 18 ]]; then
    echo "Você tem 18 anos ou mais."
    echo "Aqui está o seu ingresso para o show 1"
elif [[ ${IDADE} -ge 16 ]]; then
  echo "Você tem entre 16 ou 17 anos"
  echo "Aqui está o seu ingresso para o show 2"
else
    echo "Você não tem 18 anos ou mais."
    echo "Volte quando tiver 18"
fi

echo "Obrigado por vir no nosso show!!"