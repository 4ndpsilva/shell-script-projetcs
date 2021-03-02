#!/bin/bash


declare -A mapAliases
declare -A mapHistory
declare -A mapSizes

###################################### Recupera os aliases das imagens no formato imagem:tag - imagem:tag ######################################
lastHash=""
allHashes=()
x=0

for hash in $(docker images | grep -v "IMAGE" | grep -v \\scurrent\\s | grep -v \\slatest\\s | grep -v "<none>" | awk '{print $3}'); do
  if [ "$hash" != "$lastHash" ]; then
    lastHash=$hash
    size=$(docker inspect $hash | jq -r '.[].RepoTags | length')
    
    if [ $size -gt 0 ]; then
      i=0  
      aliases=()

      for((c=0; $c < $size; c++)) do
        aliases[$i]=$(docker inspect $hash | jq -r ".[].RepoTags[$c]")
        i=$(($i + 1))
      done

      mapAliases[$hash]=${aliases[@]}
      mapSizes[$hash]=$(docker images $hash | grep -vi IMAGE | awk '{print $NF}')  
    fi  
  fi
  
  for h in $(docker history $hash | grep -vi IMAGE | grep -v "<missing>" | awk '{ print $1 }'); do
    allHashes[$x]=$h
    x=$(($x + 1))
  done

  mapHistory[$hash]=${allHashes[@]}
done


declare -A mapRepeatedHash
declare -A mapUniqueHash

for hash in ${!mapAliases[@]}; do
    q=0
    
    for h in ${allHashes[@]}; do
      if [ "$hash" = "$h" ]; then
        q=$((q + 1))
      fi
    done

    if [ $q -gt 1 ]; then
      mapRepeatedHash[$hash]=${mapAliases[$hash]}
      unset mapAliases[$hash]
    else
      mapUniqueHash[$hash]=${mapAliases[$hash]}
    fi
  done;


for hash in ${!mapAliases[@]}; do
  #hashes=(${mapUniqueHash[$hash]})

  echo ${mapAliases[$hash]}
done