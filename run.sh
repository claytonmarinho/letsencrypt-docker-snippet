#/bin/bash

#
# SETUP
#

DATA_PATH="$HOME/.nginxdata"; #default place to save container data
NGINX_CONTAINER='nginx';
NGINX_GEN_CONTAINER='nginx-gen';
NGINX_LETSENCRYPT_CONTAINER='nginx-letsencrypt';


#getting the latest nginx.tmpl
curl https://raw.githubusercontent.com/jwilder/nginx-proxy/master/nginx.tmpl > $DATA_PATH/nginx.tmpl

#
# NGINX CONTAINER
#

#checking if there´s a container with the same name
NGINX_CHECK=$(docker ps --filter="name=$NGINX_CONTAINER" -q -a);

if [ $NGINX_CHECK ]; then
  docker rm -f $NGINX_CHECK
fi

#running container
docker run -d -p 80:80 -p 443:443 \
    --name $NGINX_CONTAINER \
    --restart always \
    -v $DATA_PATH/conf.d:/etc/nginx/conf.d  \
    -v $DATA_PATH/vhost.d:/etc/nginx/vhost.d \
    -v $DATA_PATH/html:/usr/share/nginx/html \
    -v $DATA_PATH/certs:/etc/nginx/certs:ro \
    nginx

#
# NGINX-GEN CONTAINER
#

#checking if there´s a container with the same name
NGINX_GEN_CHECK=$(docker ps --filter="name=$NGINX_GEN_CONTAINER" -q -a);

if [ $NGINX_GEN_CHECK ]; then
  docker rm -f $NGINX_GEN_CHECK
fi

#running container
docker run -d \
    --name $NGINX_GEN_CONTAINER \
    --restart always \
    --volumes-from $NGINX_CONTAINER \
    -v $DATA_PATH/nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    jwilder/docker-gen \
    -notify-sighup nginx -watch -only-exposed -wait 5s:30s /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf

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
    -e "NGINX_DOCKER_GEN_CONTAINER=$NGINX_GEN_CONTAINER" \
    --volumes-from $NGINX_CONTAINER \
    -v $DATA_PATH/certs:/etc/nginx/certs:rw \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    jrcs/letsencrypt-nginx-proxy-companion