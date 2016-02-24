#!/bin/sh
 
USERNAME=$1
DOMAIN=$2
 
if [ -z "$USERNAME" ]; then
    echo "No username received";
    exit 1;
fi
if [ -z "$DOMAIN" ]; then
    echo "No domain received";
    exit 1;
fi
 
# add to Apache's mod_fastcgi
echo "FastCGIExternalServer /dev/shm/$USERNAME-php.fcgi -socket /dev/shm/$USERNAME-php.sock -flush" >> /etc/httpd/conf.d/~mod_fastcgi.conf
 
# add PHP-FPM config for user
cat > /etc/php-fpm.d/$USERNAME.conf <<EOF
[$USERNAME]
listen = /dev/shm/$USERNAME-php.sock
listen.owner = $USERNAME
listen.group = apache
listen.mode = 0660
user = $USERNAME
pm = ondemand
# (2 x the number of processors in the server)
pm.max_children = 4
pm.max_requests = 1024
EOF
 
# enable module for vhost
sed -i "/# php: default/i \
  \  # php-fpm config (custom)\n  <IfModule mod_fastcgi.c>\n    Alias \/php.fcgi \/dev\/shm\/$USERNAME-php.fcgi\n  <\/IfModule>\n" /etc/httpd/conf.d/vhost_$DOMAIN.conf
