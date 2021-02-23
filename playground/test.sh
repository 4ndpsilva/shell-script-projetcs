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

unionHashes

for alias in ${!mapTags[@]}; do
  echo $alias
  hashes=(${mapHistoryImages[$alias]})

  for h in ${hashes[@]}; do
    echo $h
  done
  echo ""  
done

exit

for h in ${!sheets[@]}; do
  echo "$h - ${sheets[$h]}"
  echo ""
done