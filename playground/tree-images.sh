#!/bin/bash

declare -A tree
declare -A hashMapIds
declare -A hashMapSizes

images=()
c=0

#Recupera os labels das imagens no formato imagem:tag
for imageTag in $(docker images | grep -v ^53* | grep -v \\scurrent\\s | grep -v \\slatest\\s | awk '{print $1 ":" $2}'); do
  images[c]=$imageTag

  if [[ "$imageTag" = "REPOSITORY:TAG" ]] || [[ "$imageTag" = *"<none>"* ]]; then
    unset 'images[c]'
  fi

  c=$((c + 1))
done


for imageTag in ${images[@]}; do
  hashes=()
  i=0  
  
  for hash in $(docker history $imageTag | grep -vi IMAGE | grep -v "<missing>" | awk '{ print $1 }'); do
    hashes[i]=$hash
    i=$((i + 1))  
  done
  tree[$imageTag]=${hashes[@]}
  
  hashMapIds[$imageTag]=$(docker images $imageTag | grep -vi IMAGE | awk '{print $3}')
  hashMapSizes[$imageTag]=$(docker images $imageTag | grep -vi IMAGE | awk '{print $NF}')
done

for key in ${images[@]}; do
  #echo ${tree[$key]} | awk '{print $1}'

  echo ""
  echo ${hashMapSizes[$key]}
done