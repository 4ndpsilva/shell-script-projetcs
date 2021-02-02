#!/bin/bash


declare -A mapHistoryImages
declare -A mapSizes

# Recupera os labels das imagens no formato imagem:tag
for imageTag in $(docker images | grep -v ^53* | grep -v \\scurrent\\s | grep -v \\slatest\\s | awk '{print $1 ":" $2}'); do
  if [[ "$imageTag" != "REPOSITORY:TAG" ]] && [[ "$imageTag" != *"<none>"* ]]; then
    hashes=()
    i=0  
    
    for hash in $(docker history $imageTag | grep -vi IMAGE | grep -v "<missing>" | awk '{ print $1 }'); do
        hashes[i]=$hash
        i=$((i + 1))
    done
    
    mapHistoryImages[$imageTag]=${hashes[@]}
    mapSizes[$imageTag]=$(docker images $imageTag | grep -vi IMAGE | awk '{print $NF}')  
  fi
done


# Monta um map com os primeiros hashes dos históricos de cada imagem
declare -A mapImages

for key in ${!mapHistoryImages[@]}; do
  hashes=(${mapHistoryImages[$key]})
  mapImages[$key]=${hashes[0]}
done


# Monta lista de imagens com hashes repetidos (tags)
function getMapTags(){
  declare -A mapTags

  for key in ${!mapImages[@]}; do
    hash=${mapImages[$key]}
    
    local i=0
    tags=()

    for k in ${!mapImages[@]}; do
      if [ "$k" != "$key" ]; then
        hashToCompare=${mapImages[$k]}

        if [ "$hash" = "$hashToCompare" ]; then
          tags[$i]=$k 
          i=$((i + 1))
        fi    
      else
        tags[$i]=$k
        i=$((i + 1))
      fi
    done

    #MODIFICAR ESSA PARTE
    if [ ${#tags[@]} -gt 0 ]; then
      mapTags[$key]=${tags[@]}
    fi
  done  
}



# Imagens que não tem hash repetidos no seu histórico
function getMapUnique(){
  declare -A mapUnique

  for key in ${!mapImages[@]}; do
    has=0

    for tag in ${tags[@]}; do
      if [ "$key" = "$tag" ]; then
        has=1
        break
      fi
    done

    if [ $has -eq 0 ]; then
      mapUnique[$key]=${mapImages[$key]}
    fi
  done
}


function getAllHashes(){
  allHashes=()
  i=0

  for key in ${!mapHistoryImages[@]}; do
    hashes=(${mapHistoryImages[$key]})
    
    for h in ${hashes[@]}; do 
      allHashes[$i]=$h
      i=$((i + 1))
    done
  done
}


function getSheets(){
  getAllHashes

  declare -A sheets

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