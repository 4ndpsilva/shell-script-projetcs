#!/bin/bash

echo "BAIXANDO IMAGENS DOCKER..." 
echo ""

for IMAGE in $@
do
    docker pull $IMAGE
done    

echo "PROCESSO FINALIZADO"
echo ""

docker images

echo ""