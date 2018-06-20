#!/bin/sh

spawn-fcgi -s /var/run/fcgiwrap.socket -u nginx -- /usr/bin/fcgiwrap

exec nginx -g 'daemon off;'
