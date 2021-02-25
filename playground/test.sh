#!/bin/bash


source ./image-tree.sh
OUTPUT=output.log

#showImages $OUTPUT


getSeparateMaps

echo "--------IMAGES--------"
echo ""

for k in ${!mapUniqueHash[@]}; do
  echo $k
  aliases=${mapUniqueHash[$k]}

  for alias in ${aliases[@]}; do
    echo $alias
  done
  echo ""  
done

echo "--------TAGS--------"
echo ""

for k in ${!mapRepeatedHashes[@]}; do
  echo $k
  aliases=${mapRepeatedHashes[$k]}

  for alias in ${aliases[@]}; do
    echo $alias
  done
  echo ""  
done