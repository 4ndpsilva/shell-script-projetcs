#!/bin/bash

set -e

IMAGES[0]="mysql"
IMAGES[1]="postgres"
IMAGES[2]="mongo"
IMAGES[3]="redis"
IMAGES[4]="node"
IMAGES[5]="tomcat"
IMAGES[6]="payara/server-full"
IMAGES[7]="httpd"
IMAGES[8]="nginx"
IMAGES[9]="cassandra:4.0"
IMAGES[10]="mysql:5.7.32"
IMAGES[11]="python:3.10.0a3-buster"
IMAGES[12]="couchbase:6.6.1"
IMAGES[13]="redis:5.0"
IMAGES[14]="tomcat:9.0"
IMAGES[15]="python"
IMAGES[16]="cassandra"
IMAGES[17]="hello-world"
IMAGES[18]="mongo:3.6.21-xenial"
IMAGES[19]="hello-world:nanoserver-1809"
IMAGES[20]="node:current-alpine3.12"

#source ./docker-pull.sh ${IMAGES[@]}

source ./teste.sh

checkParams "main-script" "IMAGE_ENV" "TAG" "USER"
