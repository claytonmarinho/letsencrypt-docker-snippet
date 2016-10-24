DATA_PATH="$HOME/.nginxdata";

docker run -d -p 80:80 -p 443:443 \
    --name nginx \
    --restart always \
    -v $DATA_PATH/conf.d:/etc/nginx/conf.d  \
    -v $DATA_PATH/vhost.d:/etc/nginx/vhost.d \
    -v $DATA_PATH/html:/usr/share/nginx/html \
    -v $DATA_PATH/certs:/etc/nginx/certs:ro \
    nginx

docker run -d \
    --name nginx-gen \
    --restart always \
    --volumes-from nginx \
    -v ./nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    jwilder/docker-gen \
    -notify-sighup nginx -watch -only-exposed -wait 5s:30s /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf

docker run -d \
    --name nginx-letsencrypt \
    --restart always \
    -e "NGINX_DOCKER_GEN_CONTAINER=nginx-gen" \
    --volumes-from nginx \
    -v $DATA_PATH/:/etc/nginx/certs:rw \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    jrcs/letsencrypt-nginx-proxy-companion