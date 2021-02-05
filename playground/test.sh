#!/bin/bash


source ./image-tree.sh
OUTPUT=output.log

#showImages $OUTPUT

: '
getAllHashes

for i in ${allHashes[@]}; do
  echo $i
done
exit
'

getMapUnique

for key in ${!mapUnique[@]}; do
  echo $key
  echo ${mapUnique[$key]}
  echo ""
done