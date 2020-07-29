#!/usr/bin/env bash

cat <<EOF > /etc/nginx/conf.d/nagios-proxy.conf
# Proxy Pass configuration for Alerta.
server {
    listen 80;

    server_name nagios.loc;

    location / {
        proxy_pass  http://localhost:30081;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $remote_addr;
    }

}
EOF
