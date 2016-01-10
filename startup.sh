#!/bin/sh
  

 # check if there is a /config/zm folder. 
  # - If there is, and if it has content, assume the DB is in it and so update the DB.
  # - if there isn't, create it
  
  if [ "$(ls -A /config/zm)" ]; then
    echo "/config/zm not empty; creating symlink and updating schema"
    if [ "$(ls -A /var/lib/mysql/zm)" ]; then
     echo "...found existing folder at /var/lib/mysql/zm"
     echo "......stopping mysql"
     service mysql stop
     echo "......moving old db /zm"
     mv --force /var/lib/mysql/zm /var/lib/mysql/zm-old
    fi
    echo "...starting mysql"
    service mysql start
    echo "...creating temporary instance of db (to ensure references ok)"
    mysql < /usr/share/zoneminder/db/zm_create.sql
    echo "...stopping mysql"
    service mysql stop
    echo "...removing temporary db /zm"
    rm --recursive --force /var/lib/mysql/zm
    echo "...setting permissions"
    chmod --recursive --silent go+rw /config
    echo "...creating symlink"
    ln -s /config/zm/ /var/lib/mysql
    echo "...setting owner"
    chown --recursive --silent mysql:mysql /var/lib/mysql
    echo "...starting mysql"
    service mysql start
    echo "...setting permissions"
    mysql -u root -e "grant select,insert,update,delete,create,alter,index,lock tables on zm.* to 'zmuser'@localhost identified by 'zmpass';"
    echo "...updating schema"
    /usr/bin/zmupdate.pl
  else
    echo "/config/zm not found or empty; creating symlink and creating DB"
    echo "...creating /config/zm"
    mkdir --parents /config/zm
    echo "...setting permissions"
    chmod -R go+rw /config
    echo "...creating symlink"
    ln -s /config/zm/ /var/lib/mysql/
    echo "...changing owner"
    chown -R mysql:mysql /var/lib/mysql  
    echo "...starting mysql"
    service mysql start
    echo "...creating db"
    mysql < /usr/share/zoneminder/db/zm_create.sql
    echo "...setting permissions"
    mysql -u root -e "grant select,insert,update,delete,create,alter,index,lock tables on zm.* to 'zmuser'@localhost identified by 'zmpass';"
  fi

  #checking for zm.conf
  if [ "$(ls -A /config/zm.conf)" ]; then
    echo "Found /config/zm.conf so reusing"
    echo "...renaming existing /etc/zm/zm.conf"
    mv --force /etc/zm/zm.conf /etc/zm/zm.conf.install
  else
    echo "no config file found on /config/"
    echo "...moving existing file"
    mv --force /etc/zm/zm.conf /config/zm.conf
  fi
  
  # and regardless of what happened above, create a symlink to zm.conf
    echo "...creating symlink"
    ln -s /config/zm/zm.conf /etc/zm/zm.conf  
  
  #Get docker env timezone and set system timezone
  echo "setting the correct local time"
  echo $TZ > /etc/timezone
  export DEBCONF_NONINTERACTIVE_SEEN=true DEBIAN_FRONTEND=noninteractive
  dpkg-reconfigure tzdata
  
  echo "starting other services"
  service apache2 start
  service zoneminder start
