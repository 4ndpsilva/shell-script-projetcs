#!/bin/bash



keys=()
c=0

# Recupera os labels das imagens no formato imagem:tag
for imageTag in $(docker images | grep -v ^53* | grep -v \\scurrent\\s | grep -v \\slatest\\s | awk '{print $1 ":" $2}'); do
  keys[c]=$imageTag

  if [[ "$imageTag" = "REPOSITORY:TAG" ]] || [[ "$imageTag" = *"<none>"* ]]; then
    unset 'keys[c]'
  fi

  c=$((c + 1))
done



declare -A mapAllHashes
declare -A mapSizes

# Criação do map no formato image:tag -> (lista de hashes)
for imageTag in ${keys[@]}; do
  hashes=()
  i=0  
  
  for hash in $(docker history $imageTag | grep -vi IMAGE | grep -v "<missing>" | awk '{ print $1 }'); do
    hashes[i]=$hash
    i=$((i + 1))
  done
  
  mapAllHashes[$imageTag]=${hashes[@]}
  mapSizes[$imageTag]=$(docker images $imageTag | grep -vi IMAGE | awk '{print $NF}')
done




declare -A mapUniqueHashes
declare -A mapTags

#:<<'cmt'
for imageTag in ${keys[@]}; do
  hashes=(${mapAllHashes[$imageTag]})
  mapUniqueHashes[$imageTag]=${hashes[0]}
done
#cmt


# montar lista com hashes de tags repetidas
for key in ${!mapUniqueHashes[@]}; do
  hash=${mapUniqueHashes[$key]}
  
  i=0
  tags=()

  for k in ${!mapUniqueHashes[@]}; do
    if [ "$k" != "$key" ]; then
      hashToCompare=${mapUniqueHashes[$k]}

      if [ "$hash" = "$hashToCompare" ]; then
        tags[$i]=$k 
        i=$((i + 1))
      fi    
    else
      tags[$i]=$k
      i=$((i + 1))
    fi
  done

  if [ ${#tags[@]} -gt 0 ]; then
    mapTags[$key]=${tags[@]}
  fi
done  


declare -A mapUnique


for key in ${!mapUniqueHashes[@]}; do
  has=0
  for tag in ${tags[@]}; do
    if [ "$key" = "$tag" ]; then
      has=1
    fi
  done

  if [ $has -eq 0 ]; then
    echo $key
    mapUnique[$key]=${mapUniqueHashes[$key]}
  fi
done