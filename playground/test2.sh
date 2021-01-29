#!/bin/bash


function build() {
  mapAllHashes=$1
  # selecionar as hashes sem repetição
  for imageTag in ${keys[@]}; do
    hashes=(${mapAllHashes[$imageTag]})
    hash=${hashes[0]}
    
    for key in ${keys[@]}; do
      if [ "$imageTag" != "$key" ]; then
        hashesToCompare=(${mapAllHashes[$key]})
        qtd=0

        for h in ${hashesToCompare[@]}; do
          if [ "$hash" = "$h" ]; then
            qtd=$((qtd + 1))      
          fi
        done

        if [ $qtd -eq 0 ]; then
          mapUniqueHashes[$imageTag]=$hash
          break
        fi    
      fi
    done
  done       

  build ${mapUniqueHashes[@]}
}


for key in ${!mapUniqueHashes[@]}; do
  echo $key
done

for imageTag in ${keys[@]}; do
  hashes=(${mapAllHashes[$imageTag]})
  mapUniqueHashes[$imageTag]=${hashes[0]}
done

echo ""