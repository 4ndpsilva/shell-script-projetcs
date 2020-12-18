#!/bin/bash

set -e

#source ./docker-pull.sh mysql postgres mongo redis node tomcat payara/server-full httpd nginx cassandra:4.0 mysql:5.7.32 python:3.10.0a3-buster couchbase:6.6.1
#source ./docker-remove-all.sh

source ./clearDockerImages.sh $1 $2