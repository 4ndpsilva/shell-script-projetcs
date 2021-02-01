#!/bin/bash

NUMBER1=$1
NUMBER2=$2

if [ -z $"$NUMBER1" ] || [ -z $"$NUMBER2" ]; then
  echo "Necessário informar 2 números!"
  exit 1
fi

if [ "$NUMBER1" -gt "$NUMBER2" ]; then
  echo "O número $NUMBER1 é maior que $NUMBER2"
elif [ "$NUMBER2" -gt "$NUMBER1" ]; then
  echo "O número $NUMBER2 é maior que $NUMBER1"
else  
  echo "Os números são iguais"
fi