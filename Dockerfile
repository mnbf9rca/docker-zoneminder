FROM phusion/baseimage:0.9.18

MAINTAINER mnbf9rca

VOLUME ["/config"]

EXPOSE 80

RUN export DEBCONF_NONINTERACTIVE_SEEN=true DEBIAN_FRONTEND=noninteractive && \
apt-get update && \
apt-get instally \
software-properties-common \
python-software-properties && \
add-apt-repositoryy ppa:iconnor/zoneminder-master && \
apt-get update && \
apt-get install \
wget \
apache2 \
mysql-server \
php5 \
libapache2-mod-php5 \
usbutils && \
service apache2 restart && \
service mysql restart && \
apt-get instally \
zoneminder \
libvlc-dev \
libvlccore-dev vlc && \
a2enmod cgi && \
service apache2 restart && \
service mysql restart 

ADD apache.conf /etc/zm/apache.conf


RUN mkdir /etc/apache2/conf.d && \
lns /etc/zm/apache.conf /etc/apache2/conf.d/zoneminder.conf && \
lns /etc/zm/apache.conf /etc/apache2/conf-enabled/zoneminder.conf && \
adduser www-data video && \
service apache2 restart
