FROM phusion/baseimage:0.9.18

MAINTAINER mnbf9rca

VOLUME ["/config"]

EXPOSE 80

ADD startservices.sh /etc/my_init.d/startservices.sh

RUN export DEBCONF_NONINTERACTIVE_SEEN=true DEBIAN_FRONTEND=noninteractive && \
apt-get update && \
apt-get install -y \
software-properties-common \
python-software-properties && \
add-apt-repository -y ppa:iconnor/zoneminder-master && \
apt-get update && \
apt-get install -y \
wget \
apache2 \
mysql-server \
php5 \
php5-gd \
libapache2-mod-php5 \
usbutils && \
service apache2 restart && \
service mysql restart && \
apt-get install -y \
zoneminder \
libvlc-dev \
libvlccore-dev \
vlc && \
sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ Europe\/London/g' /etc/php5/cli/php.ini && \
sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ Europe\/London/g' /etc/php5/apache2/php.ini && \
mysql < /usr/share/zoneminder/db/zm_create.sql && \
service mysql stop && \
mkdir /config && \
mv /var/lib/mysql/zm /config/ && \
ln -s /config/zm/ /var/lib/mysql/zm/ && \
service mysql start && \
mysql -u root -e "grant select,insert,update,delete,create,alter,index,lock tables on zm.* to 'zmuser'@localhost identified by 'zmpass';" && \
a2enmod cgi && \
a2enmod rewrite && \
a2enconf zoneminder && \
service apache2 restart && \
service mysql restart && \
adduser www-data video && \
service apache2 restart && \
chmod 775 /etc/zm/zm.conf && \
chmod +x /etc/my_init.d/startservices.sh

CMD /etc/my_init.d/startservices.sh

