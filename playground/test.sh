#!/bin/bash


declare -A mapHistoryImages
declare -A mapSizes

# Recupera os labels das imagens no formato imagem:tag
for imageTag in $(docker images | grep -v ^53* | grep -v \\scurrent\\s | grep -v \\slatest\\s | awk '{print $1 ":" $2}'); do
  if [[ "$imageTag" != "REPOSITORY:TAG" ]] && [[ "$imageTag" != *"<none>"* ]]; then
    hashes=()
    i=0  
    
    for hash in $(docker history $imageTag | grep -vi IMAGE | grep -v "<missing>" | awk '{ print $1 }'); do
        hashes[i]=$hash
        i=$((i + 1))
    done
    
    mapHistoryImages[$imageTag]=${hashes[@]}
    mapSizes[$imageTag]=$(docker images $imageTag | grep -vi IMAGE | awk '{print $NF}')  
  fi
done