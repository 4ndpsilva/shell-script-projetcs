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
function getAllHashes(){
  allHashes=()
  local i=0

  for alias in ${!mapHistoryImages[@]}; do
    hashes=(${mapHistoryImages[$alias]})
    
    for h in ${hashes[@]}; do 
      allHashes[$i]=$h
      i=$((i + 1))
    done
    echo ""
  done
}


###################################### Monta um map com as tags de determinada imagem ######################################
declare -A mapTags

function getMapTags(){
  for alias in ${!mapFirstHash[@]}; do
    hash=${mapFirstHash[$alias]}
    
    local i=0
    tags=()
    echo $hash

    for k in ${!mapFirstHash[@]}; do
      if [ "$k" != "$alias" ]; then
        hashToCompare=${mapFirstHash[$k]}

        if [ "$hash" = "$hashToCompare" ]; then
          tags[$i]=$k 
          i=$((i + 1))
        fi    
      else
        tags[$i]=$k
        i=$((i + 1))
      fi
    done

    if [ ${#tags[@]} -gt 1 ]; then
      mapTags[$alias]=${tags[@]}
    fi
  done  
}

getMapTags

###################################### Imagens que não tem IDs repetidos no seu histórico ######################################
declare -A mapUnique

function getMapUnique(){

  for key in ${!mapFirstHash[@]}; do
    local has=0

    for tag in ${tags[@]}; do
      if [ "$key" = "$tag" ]; then
        has=1
        break
      fi
    done

    if [ $has -eq 0 ]; then
      mapUnique[$key]=${mapFirstHash[$key]}
    fi
  done
}


###################################### Monta map com imagens que podem ser apagadas ######################################
declare -A sheets

function getReclaimableImages(){
  getMapUnique
  getAllHashes

  if [ ${#mapUnique[@]} -gt 0 ] ; then
    for key in ${!mapUnique[@]}; do
      hashes=(${mapUnique[$key]})
      topHash=${hashes[0]}
      
      local qtd=0

      for hash in ${allHashes[@]}; do
        if [ "$hash" = "$topHash" ]; then
          qtd=$((qtd + 1))
        fi
      done

      if [ $qtd = 1 ]; then
        sheets[$key]=$topHash
      fi
    done
  fi
} 

function showImages(){
  OUTPUT=$1
  getReclaimableImages
  getMapTags

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