#!/bin/bash

for imageTag in $(docker images | grep -v REPOSITORY | awk '{print $1 ":" $2}'); do
  docker rmi $imageTag -f
done