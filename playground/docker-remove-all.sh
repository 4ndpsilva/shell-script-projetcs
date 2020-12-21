#!/bin/bash

echo "------------------EXCLUINDO IMAGES DOCKER------------------"
echo ""
docker rmi --force $(docker images | awk '{ print $3 }')
docker system prune --all --force --volumes
echo ""
echo "------------------PROCESSO CONCLUÍDO------------------"
echo ""

docker images