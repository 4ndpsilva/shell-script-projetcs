#!/bin/bash

declare -A treeImages
declare -A hashImageId

for imageTag in $(docker images | grep -v ^53* | grep -v \\scurrent\\s | grep -v \\slatest\\s | awk '{print $1 ":" $2}'); do
  images=()

  i=0  
  for hash in $(docker history $imageTag | grep -v IMAGE | grep -v "<missing>" | awk '{ print $1 }'); do
    images[i]=$hash
    i=$((i + 1))  
  done

  treeImages[$imageTag]=${images[@]}  
 
  i=0
  for h in $(docker images $imageTag | grep -v IMAGE | awk '{print $3}'); do
    hashImageId[$imageTag]=$h
  done
done

echo ${hashImageId[*]}