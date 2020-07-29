#!/usr/bin/env bash

# create local storage path for mongodb
mkdir -p /storage/mongodb
chmod 1777 /storage/mongodb

# setup nginx as a proxy forwarder for alerta
rm -f /etc/nginx/nginx.conf
cat <<EOF > /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
# Load dynamic modules. See /usr/share/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;
events {
    worker_connections 1024;
}
http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;
    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;
}
EOF

cat <<EOF > /etc/nginx/conf.d/alerta-proxy.conf
# Proxy Pass configuration for Alerta.
server {
    listen 80;

    server_name alerta.loc;

    location / {
        proxy_pass  http://localhost:30080;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $remote_addr;
    }

}
EOF
