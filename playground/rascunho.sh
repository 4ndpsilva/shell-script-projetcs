#!/bin/bash


declare -A map
declare -A mapHistory
declare -A mapSizes

###################################### Recupera os aliases das imagens no formato imagem:tag - imagem:tag ######################################
lastHash=""
allHashes=()
x=0

for hash in $(docker images | grep -v \\scurrent\\s | grep -v \\slatest\\s | awk '{print $3}'); do
  if [ "$hash" != "IMAGE" ]; then
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

        map[$hash]=${aliases[@]}
        mapSizes[$hash]=$(docker images $hash | grep -vi IMAGE | awk '{print $NF}')  
      fi  
    fi

    for h in $(docker history $hash | grep -vi IMAGE | grep -v "<missing>" | awk '{ print $1 }'); do
      allHashes[$x]=$h
      x=$(($x + 1))
    done
  fi
done

for h in ${allHashes[@]}; do
  echo $h
done