 
#!/bin/bash
  

 # check if there is a /config/zm folder. 
  # - If there is, and if it has content, assume the DB is in it and so update the DB.
  # - if there isn't, create it
  
  if [ "$(ls -A /config/zm)" ]; then
    echo "/config/zm not empty; creating symlink and updating schema"
    # rm /var/lib/mysql/zm # <-- not sure if we need this?
    chmod -R go+rw /config
    ln -s /config/zm/ /var/lib/mysql/
    chown -R mysql:mysql /var/lib/mysql
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
   # always update permissions for mysql     
   echo "resetting permissions"
   
  
  
  #Get docker env timezone and set system timezone
  echo "setting the correct local time"
  echo $TZ > /etc/timezone
  export DEBCONF_NONINTERACTIVE_SEEN=true DEBIAN_FRONTEND=noninteractive
  dpkg-reconfigure tzdata
  
  #fix memory issue
  echo "increasing shared memory"
  umount /dev/shm
  mount -t tmpfs -o rw,nosuid,nodev,noexec,relatime,size=${MEM:-4096M} tmpfs /dev/shm
  
  echo "starting services"
  
  service apache2 start
  service zoneminder start
