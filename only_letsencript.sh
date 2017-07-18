#/bin/bash

#
# SETUP
#

DATA_PATH="$HOME/.nginxdata"; #default place to save container data
NGINX_CONTAINER='nginx-proxy';
NGINX_LETSENCRYPT_CONTAINER='nginx-letsencrypt';

mkdir $DATA_PATH;

#
# NGINX CONTAINER
#

#checking if there´s a container with the same name
#NGINX_CHECK=$(docker ps --filter="name=$NGINX_CONTAINER" -q -a);

#if [ $NGINX_CHECK ]; then
#  docker rm -f $NGINX_CONTAINER
#fi

#running container
#docker run -d -p 80:80 -p 443:443 \
#    --name $NGINX_CONTAINER \
#    --restart always \
#    -v $DATA_PATH/certs:/etc/nginx/certs:ro \
#    -v $DATA_PATH/vhost.d:/etc/nginx/vhost.d \
#    -v $DATA_PATH/html:/usr/share/nginx/html \
#    -v /var/run/docker.sock:/tmp/docker.sock:ro \
#    jwilder/nginx-proxy

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
    -v $DATA_PATH/certs:/etc/nginx/certs:rw \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    jrcs/letsencrypt-nginx-proxy-companion
