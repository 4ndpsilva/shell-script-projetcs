#!/usr/bin/env bash

docker network create --driver bridge mysql-net

docker run --name mysqldb \
--publish 3306:3306 \
--network=mysql-net \
--env MYSQL_ROOT_HOST='%' --env MYSQL_ROOT_PASSWORD='1234' --env MYSQL_DATABASE='helpdesk_db' \
--detach mysql

docker run --name adminer --publish 5050:8080 --network=mysql-net --detach adminer