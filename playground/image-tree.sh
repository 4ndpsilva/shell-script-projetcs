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


###################################### Monta um map com as tags de determinada imagem ######################################
declare -A mapTags

function getMapTags(){
  getAllHashes
  local all=(${allHashes[@]})

  for alias in ${!mapFirstHash[@]}; do
    hash=${mapFirstHash[$alias]}  
    q=0

    for h in ${all[@]}; do
      if [ "$hash" = "$h" ]; then
        q=$((q + 1))
      fi
    done    

    if [ $q -gt 1 ]; then
      mapTags[$alias]=$hash
      unset mapFirstHash[$alias]
    fi
  done;
}


###################################### Imagens que não tem IDs repetidos no seu histórico ######################################
declare -A mapUnique

function getMapUniqueId(){

  for alias in ${!mapFirstHash[@]}; do
    mapUnique[$alias]=${mapFirstHash[$alias]}
  done
}


###################################### Monta map com imagens que podem ser apagadas ######################################
declare -A sheets

function unionHashes(){
  getMapTags
  getMapUniqueId
  
  for alias in ${!mapUnique[@]}; do
    sheets[${mapUnique[$alias]}]=$alias
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

  for key in ${!mapTags[@]}; do
    tag=$(echo $key | cut --delimiter=':' --fields=2)

    echo "TAG: $tag" >> $OUTPUT
    echo "SIZE: ${mapSizes[$key]}" >> $OUTPUT
    echo "" >> $OUTPUT
  done
}