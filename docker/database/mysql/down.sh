#!/usr/bin/env bash

docker container rm -f adminer

docker container rm -f mysqldb

docker network rm mysql-net