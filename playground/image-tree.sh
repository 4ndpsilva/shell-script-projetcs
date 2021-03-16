#!/bin/bash
#=============================================================
#
#       FILE: .../docker-db/image-tree.sh
#
#       USAGE: source ./image-tree.sh
#
#       DESCRIPTION: Scripts to show images that can be removed
#
#=============================================================
#

declare -A mapAliases
declare -A mapHistory
declare -A mapSizes

## Recupera os aliases das imagens e usa mapas cuja chave é o hash - aliases no formato image:tag
lastHash=""
allHashes=()
x=0

for line in $(docker images -f "dangling=false" | grep -v IMAGE | grep -v \\scurrent\\s | grep -v \\slatest\\s | awk '{print $3 ":" $NF}'); do
  hash=$(echo $line | cut --delimiter=':' --fields=1)
  imageSize=$(echo $line | cut --delimiter=':' --fields=2)

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

    for h in $(docker history $hash | grep -v IMAGE | grep -v "<missing>" | awk '{ print $1 }'); do
      historyHashes[$c]=$h
      c=$(($c + 1))

      allHashes[$x]=$h
      x=$(($x + 1))
    done

    mapHistory[$hash]=${historyHashes[@]}
    mapSizes[$hash]=$imageSize
  fi
done


## Separação de map com hashes repetidas e map com hashes únicas
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


## Criação de map com as tags de imagens que poderão ser removidas
declare -A mapSheets

for hash in ${!mapUniqueHash[@]}; do
  mapSheets[$hash]=${mapUniqueHash[$hash]}
  historyHashes=(${mapHistory[$hash]})
  q=0

  for h in ${!mapRepeatedHash[@]}; do
    for hh in ${historyHashes[@]}; do
      if [ "$h" = "$hh" ]; then
        q=1
        break
      fi
    done

    if [ $q -eq 1 ]; then
      hashes=(${mapRepeatedHash[$h]})

      if [ ${#hashes[@]} -gt 1 ]; then
        unset hashes[0]
        mapSheets[$h]=${hashes[@]}
      fi
    fi
  done
done


function showImages(){
  local OUTPUT=$1

  for hash in ${!mapSheets[@]}; do
    local aliases=(${mapSheets[$hash]})

    for alias in ${aliases[@]}; do
      echo "TAG: $alias" >> $OUTPUT
      echo "SIZE: ${mapSizes[$hash]}" >> $OUTPUT
      echo "" >> $OUTPUT
    done
  done
}