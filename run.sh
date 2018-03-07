#!/bin/bash

#
# SETUP
#

NGINX_CONTAINER='nginx-proxy';
NGINX_LETSENCRYPT_CONTAINER='nginx-letsencrypt';

docker volume create nginx-certs
docker volume create nginx-html
docker volume create nginx-vhost


#
# NGINX CONTAINER
#

#checking if there´s a container with the same name
NGINX_CHECK=$(docker ps --filter="name=$NGINX_CONTAINER" -q -a);

if [ $NGINX_CHECK ]; then
  docker rm -f $NGINX_CONTAINER
fi

#running container
docker run -d -p 80:80 -p 443:443 \
    --name $NGINX_CONTAINER \
    --restart always \
    -v nginx-certs:/etc/nginx/certs:ro \
    -v nginx-vhost:/etc/nginx/vhost.d \
    -v nginx-html:/usr/share/nginx/html \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    -v ./conf.d:/etc/nginx/conf.d
    jwilder/nginx-proxy

#
# NGINX-LETSENCRYPT CONTAINER
#

#checking if there´s a container with the same name
NGINX_LETSENCRYPT_CHECK=$(docker ps --filter="name=${NGINX_LETSENCRYPT_CONTAINER}" -q -a);

if [ $NGINX_LETSENCRYPT_CHECK ]; then
  docker rm -f $NGINX_LETSENCRYPT_CHECK
fi

#running container
docker run -d \
    --name $NGINX_LETSENCRYPT_CONTAINER \
    --restart always \
    --volumes-from $NGINX_CONTAINER \
    -e "DEBUG=TRUE" \
    -v nginx-certs:/etc/nginx/certs:rw \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    jrcs/letsencrypt-nginx-proxy-companion
