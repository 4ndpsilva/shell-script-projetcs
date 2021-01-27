#!/bin/bash

CONTAINER_NAME="mongo-c1"
BASE_NAME="mongo"


#step 1
docker run --name $CONTAINER_NAME $BASE_NAME /bin/bash
docker commit $CONTAINER_NAME $BASE_NAME:current
docker container prune -f

docker run --name $CONTAINER_NAME $BASE_NAME:current /bin/bash
docker commit $CONTAINER_NAME $BASE_NAME:v1
docker container prune -f


#step 2
docker run --name $CONTAINER_NAME $BASE_NAME:v1 /bin/bash
docker commit $CONTAINER_NAME $BASE_NAME:v1.1
docker commit $CONTAINER_NAME $BASE_NAME:v1.2
docker container prune -f

docker run --name $CONTAINER_NAME $BASE_NAME:v1.1 /bin/bash
docker commit $CONTAINER_NAME $BASE_NAME:v1.1.1
docker container prune -f


#step 3
docker run --name $CONTAINER_NAME $BASE_NAME:v1.2 /bin/bash
docker commit $CONTAINER_NAME $BASE_NAME:v1.2.1
docker container prune -f

docker tag $BASE_NAME:v1.2 v1.2:tag1
docker tag $BASE_NAME:v1.2 v1.2:tag2