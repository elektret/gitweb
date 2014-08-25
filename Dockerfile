FROM debian:wheezy
MAINTAINER Manuel Bieling "manuel@elektret.de"
WORKDIR ~/

RUN apt-get update
RUN apt-get install -y nginx \
                       fcgiwrap \
                       spawn-fcgi \
                       openssh-server \
                       git \
                       gitweb

# CREATE USER
RUN useradd -Umd /home/gitweb gitweb -s /bin/bash

# GITWEB
RUN mkdir -p /var/run/sshd; \
    mkdir -p /var/www/gitweb; \
    mkdir -p /home/gitweb/repos; \
    mkdir -p /home/gitweb/.ssh

# CHROOT
RUN mkdir -p /home/gitweb/dev; \
    mkdir -p /home/gitweb/etc; \
    mkdir -p /home/gitweb/bin; \
    mkdir -p /home/gitweb/lib64; \
    mkdir -p /home/gitweb/usr/bin; \
    mkdir -p /home/gitweb/usr/share; \
    mkdir -p /home/gitweb/usr/lib/x86_64-linux-gnu; \
    mkdir -p /home/gitweb/lib/x86_64-linux-gnu

RUN mknod -m 666 /home/gitweb/dev/null c 1 3; \
    mknod -m 666 /home/gitweb/dev/zero c 1 5

RUN cp /etc/ld.so.cache /home/gitweb/etc/; \
    cp /etc/ld.so.conf /home/gitweb/etc/; \
    cp /etc/nsswitch.conf /home/gitweb/etc/; \
    cp /etc/hosts /home/gitweb/etc/

RUN cp /bin/ls /home/gitweb/bin/; \
    cp /bin/sh /home/gitweb/bin/; \
    cp /bin/rm /home/gitweb/bin/; \
    cp /bin/cp /home/gitweb/bin/; \
    cp /bin/df /home/gitweb/bin/; \
    cp /bin/cat /home/gitweb/bin/; \
    cp /bin/bash /home/gitweb/bin/; \
    cp /bin/true /home/gitweb/bin/; \
    cp /bin/echo /home/gitweb/bin/; \
    cp /bin/grep /home/gitweb/bin/; \
    cp /bin/less /home/gitweb/bin/; \
    cp /bin/mkdir /home/gitweb/bin/; \
    cp /bin/rmdir /home/gitweb/bin/

RUN cp /usr/bin/git /home/gitweb/usr/bin/; \
    cp /usr/bin/git-shell /home/gitweb/usr/bin/; \
    cp /usr/bin/git-receive-pack /home/gitweb/usr/bin/; \
    cp /usr/bin/git-upload-pack /home/gitweb/usr/bin/; \
    cp /usr/bin/git-upload-archive /home/gitweb/usr/bin/; \
    cp -r /usr/share/git-core /home/gitweb/usr/share

RUN cp /lib64/ld-linux-x86-64.so.2 /home/gitweb/lib64/; \
    cp /lib/x86_64-linux-gnu/libselinux.so.1 /home/gitweb/lib/x86_64-linux-gnu/; \
    cp /lib/x86_64-linux-gnu/librt.so.1 /home/gitweb/lib/x86_64-linux-gnu/; \
    cp /lib/x86_64-linux-gnu/libacl.so.1 /home/gitweb/lib/x86_64-linux-gnu/; \
    cp /lib/x86_64-linux-gnu/libc.so.6 /home/gitweb/lib/x86_64-linux-gnu/; \
    cp /lib/x86_64-linux-gnu/libdl.so.2 /home/gitweb/lib/x86_64-linux-gnu/; \
    cp /lib/x86_64-linux-gnu/libpthread.so.0 /home/gitweb/lib/x86_64-linux-gnu/; \
    cp /lib/x86_64-linux-gnu/libattr.so.1 /home/gitweb/lib/x86_64-linux-gnu/; \
    cp /lib/x86_64-linux-gnu/libz.so.1 /home/gitweb/lib/x86_64-linux-gnu/; \
    cp /lib/x86_64-linux-gnu/libtinfo.so.5 /home/gitweb/lib/x86_64-linux-gnu/; \
    cp /lib/x86_64-linux-gnu/libresolv.so.2 /home/gitweb/lib/x86_64-linux-gnu/; \
    cp /usr/lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /home/gitweb/usr/lib/x86_64-linux-gnu/

# NGINX
ADD gitweb.server /etc/nginx/sites-available/gitweb
RUN ln -s /etc/nginx/sites-available/gitweb /etc/nginx/sites-enabled/; \
    rm -rf /etc/nginx/sites-enabled/default

# SSH
ADD gitweb_rsa.pub /home/gitweb/.ssh/gitweb_rsa.pub
RUN cat /home/gitweb/.ssh/gitweb_rsa.pub > /home/gitweb/.ssh/authorized_keys; \
    passwd -l root; \
    passwd -l gitweb

# GITWEB
RUN cp -r /usr/share/gitweb/static /var/www/gitweb/; \
    cp /usr/share/gitweb/gitweb.cgi /var/www/gitweb/

# ENV
RUN chown -R gitweb:gitweb /home/gitweb/.ssh; \
    chown -R gitweb:gitweb /var/www; \
    chown gitweb:gitweb /home/gitweb/repos; \
    chown root:root /home/gitweb

# CONFIG
ADD nginx.conf /etc/nginx/nginx.conf
ADD gitweb.conf /etc/gitweb.conf
ADD sshd.conf /etc/ssh/sshd_config

RUN chmod 644 /etc/gitweb.conf

EXPOSE 22 80

ADD start.sh /start.sh
CMD ["/bin/sh", "/start.sh"]
