#!/usr/bin/env bash

docker container rm -f pgadmin

docker container rm -f postgresqldb

docker network rm postgresql-net