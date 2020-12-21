#!/bin/bash

IMAGES=$1

echo "BAIXANDO IMAGENS DOCKER...\n" 

for IMAGE in ${IMAGES[@]}
do
    docker pull $IMAGE
done    

echo "\n PROCESSO FINALIZADO \n"

docker images

echo ""