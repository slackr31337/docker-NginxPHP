#!/bin/sh
chown -R www-data:www-data /var/www/html/*
/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
