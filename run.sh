docker run -d -p 80:80 -p 443:443 \
    --name nginx \
    -v $HOME/.nginxdata/conf.d:/etc/nginx/conf.d  \
    -v $HOME/.nginxdata/vhost.d:/etc/nginx/vhost.d \
    -v $HOME/.nginxdata/html:/usr/share/nginx/html \
    -v $HOME/.nginxdata/certs:/etc/nginx/certs:ro \
    nginx

docker run -d \
    --name nginx-gen \
    --volumes-from nginx \
    -v ./nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    jwilder/docker-gen \
    -notify-sighup nginx -watch -only-exposed -wait 5s:30s /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf
