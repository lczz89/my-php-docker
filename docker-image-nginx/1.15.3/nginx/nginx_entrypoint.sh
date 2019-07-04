#!/bin/bash

mkdir -p /home/logs/ 
touch /home/logs/hj_house.access_log
cp ./fastcgi.conf /etc/nginx/fastcgi.conf
mkdir -p /home/www/hj_house 
touch /home/www/hj_house/index.php 
echo '<?php echo phpinfo();'>/home/www/hj_house/index.php
exec nginx -g 'daemon off;'
