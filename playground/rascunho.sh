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
      aliases=()

      for((c=0; $c < $size; c++)) do
        aliases[$c]=$(docker inspect $hash | jq -r ".[].RepoTags[$c]")
      done

      mapAliases[$hash]=${aliases[@]}
    fi  

    c=0
    historyHashes=()

    for h in $(docker history $hash | grep -vi IMAGE | grep -v "<missing>" | awk '{ print $1 }'); do
      historyHashes[$c]=$h
      c=$(($c + 1))

      allHashes[$x]=$h
      x=$(($x + 1))
    done

    mapHistory[$hash]=${historyHashes[@]}
    mapSizes[$hash]=$(docker images $hash | grep -vi IMAGE | awk '{print $NF}')  
  fi
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
  else
    mapUniqueHash[$hash]=${mapAliases[$hash]}
  fi
done;



for hash in ${!mapHistory[@]}; do
  hashes=(${mapRepeatedHash[$hash]})
  q=0
  
  for h in ${hashes[@]}; do
    if [ "$hash" = "$h" ]; then
      q=$((q + 1))
    fi
  done

  if [ $q -gt 1 ]; then
    echo ${mapRepeatedHash[$hash]}
  fi  
done