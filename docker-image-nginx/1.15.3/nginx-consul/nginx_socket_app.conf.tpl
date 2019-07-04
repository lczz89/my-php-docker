server {
    listen 80;
    server_name NGINX_SERVER_NAME;

    #access_log /home/logs/ws.jdd.access_log logstash;
    #error_log /home/logs/ws.jdd.error_log;

    location / {
        proxy_pass NGINX_PASS_ADDRESS;
        #proxy_set_header X-Real-IP $remote_addr;
        #proxy_set_header X-Forwarded-Host $host;
        #proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}