#!/bin/bash

declare -A tree
declare -A hashMapSizes
declare -A hashMapReclaimable

keys=()
c=0

#Recupera os labels das imagens no formato imagem:tag
for imageTag in $(docker images | grep -v ^53* | grep -v \\scurrent\\s | grep -v \\slatest\\s | awk '{print $1 ":" $2}'); do
  keys[c]=$imageTag

  if [[ "$imageTag" = "REPOSITORY:TAG" ]] || [[ "$imageTag" = *"<none>"* ]]; then
    unset 'keys[c]'
  fi

  c=$((c + 1))
done


# Criação do map [image:tag] -> (lista de hashes)
for imageTag in ${keys[@]}; do
  hashes=()
  i=0  
  
  for hash in $(docker history $imageTag | grep -vi IMAGE | grep -v "<missing>" | awk '{ print $1 }'); do
    hashes[i]=$hash
    i=$((i + 1))
  done
  
  tree[$imageTag]=${hashes[@]}
  hashMapSizes[$imageTag]=$(docker images $imageTag | grep -vi IMAGE | awk '{print $NF}')
done


# selecionar as hashes sem repetição
for imageTag in ${keys[@]}; do
  hashes=(${tree[$imageTag]})
  hash=${hashes[0]}
  
  for key in ${keys[@]}; do
    if [ "$imageTag" != "$key" ]; then
      hashes2=(${tree[$key]})
      qtd=0

      for h in ${hashes2[@]}; do
        if [ "$hash" = "$h" ]; then
          qtd=$((qtd + 1))      
        fi
      done

      if [ $qtd -eq 0 ]; then
        hashMapReclaimable[$imageTag]=$hash
        break
      fi    
    fi
  done
done

#Exibição da lista de imagens e/ou tags
for key in ${hashMapReclaimable[@]}; do
  echo "$key"
done  