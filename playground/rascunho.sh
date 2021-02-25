#!/bin/bash


declare -A mapHistoryImages
declare -A mapSizes

###################################### Recupera os aliases das imagens no formato imagem:tag - imagem:tag ######################################
for alias in $(docker images | grep -v \\scurrent\\s | grep -v \\slatest\\s | awk '{print $1 ":" $2}'); do
  if [[ "$alias" != "REPOSITORY:TAG" ]] && [[ "$alias" != *"<none>"* ]]; then
    hashes=()
    i=0  
    echo $alias
    for hash in $(docker history $alias | grep -vi IMAGE | grep -v "<missing>" | awk '{ print $1 }'); do
        hashes[i]=$hash
        i=$((i + 1))
        echo "  $hash"
    done
    echo ""
    mapHistoryImages[$alias]=${hashes[@]}
    mapSizes[$alias]=$(docker images $alias | grep -vi IMAGE | awk '{print $NF}')
  fi
done