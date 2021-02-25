#!/bin/bash


source ./image-tree.sh
OUTPUT=output.log


#showImages $OUTPUT

#exit 
getSeparateMaps

echo "--------IMAGES--------"
echo ""

for alias in ${!mapUniqueHash[@]}; do
  echo $alias
  echo ${mapUniqueHash[$alias]}
  echo ""  
done

echo "--------TAGS--------"
echo ""

for alias in ${!mapRepeatedHash[@]}; do
  echo $alias
  echo ${mapRepeatedHash[$alias]}
  echo ""  
done