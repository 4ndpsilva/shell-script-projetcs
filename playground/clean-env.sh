#!/bin/bash

images=()
c=0

#Recupera os labels das imagens no formato imagem:tag
for imageTag in $(docker images | grep -v ^53* | grep -v \\scurrent\\s | grep -v \\slatest\\s | awk '{print $1 ":" $2}'); do
  images[c]=$imageTag

  if [ "$imageTag" = "REPOSITORY:TAG" ]; then
    unset 'images[c]'
  fi

  c=$((c + 1))
done

for imageTag in ${images[@]}; do
    if [[ "$imageTag" = *"<none>"* ]]; then
      docker image prune -f
    else
      docker rmi $imageTag -f
    fi
done