#!/bin/bash
sudo cat > /etc/nginx/nginx.conf <<EOL
worker_processes auto;
include /usr/share/nginx/modules/*.conf;
events {
    worker_connections 1024;
}
http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    error_log /dev/null;
    access_log /dev/null;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name _;
        location / {
            proxy_pass http://${lb_dns_name};
        }
    }
}
EOL
sudo service nginx restart