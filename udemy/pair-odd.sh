#!/bin/bash

OP=1
while [ "$OP" = 1 ]; do
    clear
    OP=0
    echo "================PROGRAMA PAR OU IMPAR==================="
    echo "1 - Para Continuar"
    echo "Qualquer outra tecla para Sair"
    echo "========================================================"
    echo "Deseja sair ou continuar no programa?"
    read OP

    if [ "$OP" = 1 ]; then
      echo "Digite um número: "
      read NUMBER

      if [ $((NUMBER % 2)) = 0 ]; then
        echo "O número $NUMBER é Par"
      else
        echo "O número $NUMBER é Impar"
      fi  
    else
      echo "Finalizando..."
      sleep 1s
      echo "Obrigado por participar!"
      break
    fi

    sleep 3s  
done