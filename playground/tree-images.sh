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



declare -A mapHistoryImages
declare -A mapSizes

# Criação do map no formato image:tag -> (lista de hashes)
for imageTag in ${keys[@]}; do
  hashes=()
  i=0  
  
  for hash in $(docker history $imageTag | grep -vi IMAGE | grep -v "<missing>" | awk '{ print $1 }'); do
    hashes[i]=$hash
    i=$((i + 1))
  done
  
  mapHistoryImages[$imageTag]=${hashes[@]}
  mapSizes[$imageTag]=$(docker images $imageTag | grep -vi IMAGE | awk '{print $NF}')
done




declare -A mapImages

for imageTag in ${keys[@]}; do
  hashes=(${mapHistoryImages[$imageTag]})
  mapImages[$imageTag]=${hashes[0]}
done


# montar lista de tags com hashes repetidos
declare -A mapTags

for key in ${!mapImages[@]}; do
  hash=${mapImages[$key]}
  
  i=0
  tags=()

  for k in ${!mapImages[@]}; do
    if [ "$k" != "$key" ]; then
      hashToCompare=${mapImages[$k]}

      if [ "$hash" = "$hashToCompare" ]; then
        tags[$i]=$k 
        i=$((i + 1))
      fi    
    else
      tags[$i]=$k
      i=$((i + 1))
    fi
  done

# modificar essa parte
  if [ ${#tags[@]} -gt 0 ]; then
    mapTags[$key]=${tags[@]}
  fi
done  


# Imagens que não tem hash repetidos
declare -A mapUnique

for key in ${!mapImages[@]}; do
  has=0
  for tag in ${tags[@]}; do
    if [ "$key" = "$tag" ]; then
      has=1
      break
    fi
  done

  if [ $has -eq 0 ]; then
    mapUnique[$key]=${mapImages[$key]}
  fi
done

for k in ${!mapHistoryImages[@]}; do
  echo $k
  hashes=(${mapHistoryImages[$k]}) 
  
  for i in ${hashes[@]}; do
    echo "---- $i"
  done
  echo "" 
done