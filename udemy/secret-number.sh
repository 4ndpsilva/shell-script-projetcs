#!/bin/bash

OP="S"
while [ "$OP" = "S" ] || [ "$OP" = "s" ]; do
    clear
    echo "===================JOGO DE ADIVINHAÇÃO=================="
    echo "Descubra o número secreto de 1 a 10"
    echo "Você quer jogar? Pressione S para Sim ou qualquer outra tecla para Não"
    read OP

    if [ "$OP" = "S" ] || [ "$OP" = "s" ]; then
        SECRET_NUMBER=$((( $RANDOM % 10 ) + 1))
        NUMBER=-1
        MSG="Entre 1 e 10 qual é o número? Quer sair do jogo? Digite 0 (Zero)"
        
        while [ $SECRET_NUMBER -ne $NUMBER ] && [ $NUMBER -ne 0 ]; do
          clear  
          echo "$MSG"
          read NUMBER

          if [ $NUMBER -ne 0 ]; then
            if [ $SECRET_NUMBER -ne $NUMBER ]; then  
                MSG="Você ERROU!!! Tente novamente ou digite 0 (Zero) para sair"
            else
                echo "PARABÉNS!!! VOCÊ ACERTOU!!"  
                echo "Número secreto: $SECRET_NUMBER"  
                sleep 3s
            fi
          fi  
        done
    fi
done

echo "Finalizando..."
sleep 1s
echo "Obrigado por participar!"