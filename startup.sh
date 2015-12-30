#!/bin/sh
  

 # check if there is a /config/zm folder. 
  # - If there is, and if it has content, assume the DB is in it and so update the DB.
  # - if there isn't, create it
  
  if [ "$(ls -A /config/zm)" ]; then
    echo "/config/zm not empty; creating symlink and updating schema"
    if [ "$(ls -A /var/lib/mysql/zm)" ]; then
     echo "moving old db /zm"
     service mysql stop
     mv --force /var/lib/mysql/zm /var/lib/mysql/zm-old
    fi
    chmod --recursive --silent go+rw /config
    ln -s /config/zm/ /var/lib/mysql/
    chown --recursive --silent mysql:mysql /var/lib/mysql
    service mysql start
    mysql -u root -e "grant select,insert,update,delete,create,alter,index,lock tables on zm.* to 'zmuser'@localhost identified by 'zmpass';"
    /usr/bin/zmupdate.pl
  else
    echo "/config/zm not found or empty; creating symlink and creating DB"
    mkdir --parents /config/zm
    chmod -R go+rw /config
    ln -s /config/zm/ /var/lib/mysql/
    chown -R mysql:mysql /var/lib/mysql  
    service mysql start
    mysql < /usr/share/zoneminder/db/zm_create.sql
    mysql -u root -e "grant select,insert,update,delete,create,alter,index,lock tables on zm.* to 'zmuser'@localhost identified by 'zmpass';"
  fi

   
  
  
  #Get docker env timezone and set system timezone
  echo "setting the correct local time"
  echo $TZ > /etc/timezone
  export DEBCONF_NONINTERACTIVE_SEEN=true DEBIAN_FRONTEND=noninteractive
  dpkg-reconfigure tzdata
  
  echo "starting other services"
  service apache2 start
  service zoneminder start

#exit zero so we stay running - see what's wrong in logs??
exit 0
