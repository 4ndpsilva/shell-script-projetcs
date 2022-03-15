#!/usr/bin/env bash

docker network create --driver bridge postgresql-net

docker run --name postgresqldb \
--publish 5432:5432 \
--network=postgresql-net \
--env POSTGRES_PASSWORD='1234' \
--detach postgres

docker run --name pgadmin \
--publish 5050:80 \
--network=postgresql-net \
--env PGADMIN_DEFAULT_EMAIL='admin@provider.com' --env --PGADMIN_DEFAULT_PASSWORD='1234' \
--detach dpage/pgadmin4