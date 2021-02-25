#!/bin/bash


declare -A mapHistoryImages
declare -A mapSizes

###################################### Recupera os aliases das imagens no formato imagem:tag - imagem:tag ######################################
for alias in $(docker images | grep -v \\scurrent\\s | grep -v \\slatest\\s | awk '{print $1 ":" $2}'); do
  if [[ "$alias" != "REPOSITORY:TAG" ]] && [[ "$alias" != *"<none>"* ]]; then
    hashes=()
    i=0  
    
    for hash in $(docker history $alias | grep -vi IMAGE | grep -v "<missing>" | awk '{ print $1 }'); do
        hashes[i]=$hash
        i=$((i + 1))
    done
    
    mapHistoryImages[$alias]=${hashes[@]}
    mapSizes[$alias]=$(docker images $alias | grep -vi IMAGE | awk '{print $NF}')  
  fi
done


###################################### Monta um map com o primeiro ID do histórico de cada imagem ######################################
declare -A mapFirstHash

for alias in ${!mapHistoryImages[@]}; do
  hashes=(${mapHistoryImages[$alias]})
  mapFirstHash[$alias]=${hashes[0]}
done


###################################### Monta um array com todos IDs de todas imagens ######################################
allHashes=()

function getAllHashes(){  
  local i=0

  for alias in ${!mapHistoryImages[@]}; do
    hashes=(${mapHistoryImages[$alias]})
    
    for h in ${hashes[@]}; do 
      allHashes[$i]=$h
      i=$((i + 1))
    done
  done
}


###################################### Separação de map com hashes repetidas e map com hashes únicas ######################################
declare -A mapRepeatedHash
declare -A mapUniqueHash

function getSeparateMaps(){
  getAllHashes

  for alias in ${!mapFirstHash[@]}; do
    hash=${mapFirstHash[$alias]}  
    q=0
    
    for h in ${allHashes[@]}; do
      if [ "$hash" = "$h" ]; then
        q=$((q + 1))
      fi
    done

    if [ $q -gt 1 ]; then
      mapRepeatedHash[$alias]=$hash
      unset mapFirstHash[$alias]
    else
      mapUniqueHash[$alias]=$hash
    fi
  done;
}


###################################### Monta map com imagens que podem ser apagadas ######################################
declare -A sheets

function unionHashes(){
  getSeparateMaps
  
  for alias in ${!mapUniqueHash[@]}; do
    sheets[$alias]=${mapUniqueHash[$aliases]}
  done 

  for alias in ${!mapRepeatedHash[@]}; do
    hashes=(${mapHistoryImages[$alias]})
    q=0

    #for h in ${hashes[@]}; do
        
    #done

    if [ $q -gt 1 ]; then
      sheets[$alias]=$hash
    fi
  done
} 


function showImages(){
  OUTPUT=$1
  unionHashes

  for key in ${!sheets[@]}; do
    tag=$(echo $key | cut --delimiter=':' --fields=2)

    echo "TAG: $tag" >> $OUTPUT
    echo "SIZE: ${mapSizes[$key]}" >> $OUTPUT
    echo "" >> $OUTPUT
  done
}