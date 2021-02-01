#!/bin/bash


function build() {
i=0
for key in ${!mapUnique[@]}; do
  hashes=(${mapUnique[$key]})
  topHash=${hashes[0]}
  echo $topHash
  
  for k in ${!mapUnique[@]}; do
    if [ "$key" != "$k" ]; then
      hashesToCompare=(${mapUnique[$key]})
      qtd=0
  
      for h in ${hashesToCompare[@]}; do
        if [ "$topHash" != "$h" ]; then
          qtd=$((qtd + 1))      
        fi
      done

      if [ $qtd -eq 0 ]; then
        sheets[$i]=$key
        i=$((i + 1))
        echo ${sheets[$i]}
        break
      fi    
    fi
  done
done     
}


for key in ${!mapUniqueHashes[@]}; do
  echo $key
done

for imageTag in ${keys[@]}; do
  hashes=(${mapAllHashes[$imageTag]})
  mapUniqueHashes[$imageTag]=${hashes[0]}
done

echo ""





: '
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
'
