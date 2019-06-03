#!/bin/sh -e

spawn-fcgi -s /var/run/fcgiwrap.socket -u nginx -- /usr/bin/fcgiwrap 2>&1

exec nginx -g 'daemon off;' 2>&1
