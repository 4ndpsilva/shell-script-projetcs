#!/bin/bash

NP=$#
USER=$(for i in $@; do :; done; echo "$i")

function checkParams(){
  if [ ! "$NP" -gt 0 ]; then
    PARAMS=""
    OPT=""
    ARRAY=$*

    for PARAM in ${ARRAY[@]}; do  
      if [ "$PARAM" != $1 ] && [ "$PARAM" != ${!#} ]; then
        PARAMS=$PARAMS""$PARAM" "
      fi
    done

    echo "How to use: ./$1.sh $PARAMS(${!#})"
    exit 1
  fi
}