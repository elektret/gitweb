#!/bin/sh
/usr/bin/spawn-fcgi -F 1 \
  -s /var/run/fcgiwrap.socket \
  -u gitweb \
  -U gitweb \
  -g gitweb \
  -G gitweb /usr/sbin/fcgiwrap
/usr/sbin/nginx
/usr/sbin/sshd -D
