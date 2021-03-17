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
allHashes=()

## Recupera os aliases das imagens e usa mapas cuja chave é o hash - aliases no formato image:tag

function getMapImages(){
  local lastHash=""
  local x=0

  for line in $(docker images -f "dangling=false" | grep -v IMAGE | grep -v \\scurrent\\s | grep -v \\slatest\\s | awk '{print $3 ":" $NF}'); do
    local hash=$(echo $line | cut --delimiter=':' --fields=1)
    local imageSize=$(echo $line | cut --delimiter=':' --fields=2)

    if [ "$hash" != "$lastHash" ]; then
      lastHash=$hash
      local size=$(docker inspect $hash | jq -r '.[].RepoTags | length' | grep -v :current | grep -v :latest)

      if [ $size -gt 0 ]; then
        aliases=()

        for((c=0; $c < $size; c++)) do
          alias=$(docker inspect $hash | jq -r ".[].RepoTags[$c]" | grep -v :current | grep -v :latest)

          if [ -n "$alias" ]; then
            aliases[$c]=$alias
          fi
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
}


## Separação de map com hashes repetidas e map com hashes únicas
declare -A mapRepeatedHash
declare -A mapUniqueHash

function mapSeparator(){
  for hash in ${!mapAliases[@]}; do
    local q=0

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
}


## Trecho para fazer a unificação de um map com as imagens que poderão ser removidas
declare -A mapSheets

function createMapSheets(){
  for hash in ${!mapUniqueHash[@]}; do
    mapSheets[$hash]=${mapUniqueHash[$hash]}
    historyHashes=(${mapHistory[$hash]})
    local q=0

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
}


function showImages(){
  local OUTPUT=$1

  getMapImages
  mapSeparator
  createMapSheets

  if [ ${#mapSheets[@]} -gt 0 ]; then
    echo "------------------------------------------------------------------------------------------------" >> $OUTPUT
    echo "IMAGES THAT CAN BE REMOVED: " >> $OUTPUT
    echo "" >> $OUTPUT

    for hash in ${!mapSheets[@]}; do
      local aliases=(${mapSheets[$hash]})

      for alias in ${aliases[@]}; do
        echo "TAG: $alias" >> $OUTPUT
        echo "SIZE: ${mapSizes[$hash]}" >> $OUTPUT
        echo "" >> $OUTPUT
      done
    done

    echo "------------------------------------------------------------------------------------------------" >> $OUTPUT
  fi  
}