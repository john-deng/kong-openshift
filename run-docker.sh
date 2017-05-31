#!/bin/bash

function remove_exist_container() {

    container=$1

    res=$(docker inspect --format="{{ .State.Status }}" kong)

    if [ ${res} != "running" ]; then
        echo "'$container' does not exist."
    else
        docker rm --force $container
    fi
}

remove_exist_container kong-database

docker run -d --name kong-database \
    --privileged=true \
    --restart=always \
    -v "$PWD/datadir":/var/lib/cassandra \
    -p 9042:9042 \
    cassandra:3

remove_exist_container kong

docker run -d --name kong \
    --privileged=true \
    --restart=always \
    --link kong-database:kong-database \
    -e "KONG_DATABASE=cassandra" \
    -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
    -e "KONG_PG_HOST=kong-database" \
    -p 8000:8000 \
    -p 8446:8443 \
    -p 8001:8001 \
    -p 7946:7946 \
    -p 7946:7946/udp \
    kong:latest

remove_exist_container kong-dashboard

docker run -d --name kong-dashboard \
    --privileged=true \
    --restart=always \
    -p 8080:8080 \
    pgbi/kong-dashboard:v2 \
    npm start -- -p 8080 -a user=vpc1ub

