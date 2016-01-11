#!/bin/sh

# first, remove the existing mySQL data folder
 echo "Stopping mysql"
 service mysql stop

# check if there is a /config/mysql folder. 
# - If there is, and if it has content, assume the DB is in it and so update the DB.
# - if there isn't, create it

if [ "$(ls -Ad /config/mysql)" ]; then
	echo "/config/mysql exists; creating symlink and updating schema"
	echo -n "...creating symlink ..."
	ln -s /config/mysql /var/lib/
		if [ "$?" = "0" ]; then
			echo "OK"
		else
			echo "Failed"
			exit 35
		fi	
	echo -n "...setting permissions ... "
	chmod --recursive --silent go+rw /config
		if [ "$?" = "0" ]; then
			echo "OK"
		else
			echo "Failed"
			exit 34
		fi
		
	echo -n "...setting owner ... "
	chown --recursive --silent mysql:mysql /var/lib/mysql
		if [ "$?" = "0" ]; then
			echo "OK"
		else
			echo "Failed"
			exit 36
		fi
	echo "...starting mysql"
	service mysql start
		if [ "$?" = "0" ]; then
			echo "MySQL started"
		else
			echo "Failed to start MySQL"
			exit 37
		fi
	echo -n "...setting permissions on mysql database ..."
	mysql -u root -e "grant select,insert,update,delete,create,alter,index,lock tables on zm.* to 'zmuser'@localhost identified by 'zmpass';"
		if [ "$?" = "0" ]; then
			echo "OK"
		else
			echo "Failed"
			exit 38
		fi
	echo "...updating schema"
	/usr/bin/zmupdate.pl
else
	echo "/config/mysql not found; creating symlink and creating DB"
	
	echo -n "...moving existing mysql data dir /var/lib/mysql/ to /config/mysql ... "
	 mv --force /var/lib/mysql /config/
	 if [ "$?" = "0" ]; then
			echo "OK"
		else
			echo "Failed"
			exit 30
	fi

	echo -n "...setting permissions ..."
	chmod -R go+rw /config
		if [ "$?" = "0" ]; then
			echo "OK"
		else
			echo "Failed"
			exit 42
		fi

	
	echo -n "...creating symlink ... "
	ln -s /config/mysql /var/lib/
		if [ "$?" = "0" ]; then
			echo "OK"
		else
			echo "Failed"
			exit 43
		fi
	echo -n "...changing owner /var/lib/mysql ... "
	chown -R mysql:mysql /var/lib/mysql	
		if [ "$?" = "0" ]; then
			echo "OK"
		else
			echo "Failed"
			exit 44
		fi
	echo "...starting mysql"
	service mysql start
			if [ "$?" = "0" ]; then
		 echo "MySQL started"
		else
			echo "Failed to start MySQL"
			exit 45
		fi
	echo -n "...creating db ..."
	mysql < /usr/share/zoneminder/db/zm_create.sql
			if [ "$?" = "0" ]; then
			echo "OK"
		else
			echo "Failed"
			exit 46
		fi
	echo -n "...setting permissions ... "
	mysql -u root -e "grant select,insert,update,delete,create,alter,index,lock tables on zm.* to 'zmuser'@localhost identified by 'zmpass';"
		if [ "$?" = "0" ]; then
			echo "OK"
		else
			echo "Failed"
			exit 47
		fi
fi

#checking for zm.conf
if [ "$(ls -A /config/zm.conf)" ]; then
	echo "Found /config/zm.conf so reusing"
	echo -n "...renaming existing /etc/zm/zm.conf ... "
	mv --force /etc/zm/zm.conf /etc/zm/zm.conf.install
		if [ "$?" = "0" ]; then
			echo "OK"
		else
			echo "Failed"
			exit 51
		fi
else
	echo "no config file found on /config/"
	echo -n "...moving existing file ... "
	mv --force /etc/zm/zm.conf /config/zm.conf
		if [ "$?" = "0" ]; then
			echo "OK"
		else
			echo "Failed"
			exit 52
		fi
fi

# and regardless of what happened above, create a symlink to zm.conf
	echo -n "...creating symlink /config/zm.conf --> /etc/zm/zm.conf ... "
	ln -s /config/zm.conf /etc/zm/zm.conf
		if [ "$?" = "0" ]; then
		 echo "OK"
		else
			echo "Failed"
			exit 53
		fi
	echo -n "...setting permissions on zm.conf ... "
	chown www-data:www-data /etc/zm/zm.conf
		if [ "$?" = "0" ]; then
			echo "OK"
		else
			echo "Failed"
			exit 54
		fi
		
# check and set permissions on event dirs
# from https://github.com/ZoneMinder/ZoneMinder/blob/master/zmlinkcontent.sh.in
echo "Checking whether /var/cache/zoneminder/events exists"
if [ "$(ls -Ad /var/cache/zoneminder/events)" ]; then
	echo "... found /var/cache/zoneminder/events so not creating a new one"
else
	echo "... didn't find /var/cache/zoneminder/events folder"
	echo -n "... creating folder"
	mkdir /var/cache/zoneminder/events
		if [ "$?" = "0" ]; then
			echo "OK"
		else
			echo "Failed"
			exit 55
		fi	 	
fi
echo -n "... changing ownership of the events folder recursively to www-data:www-data ... "
chown -R www-data:www-data "/var/cache/zoneminder/events"
	if [ "$?" = "0" ]; then
		echo "OK"
	else
		echo "Failed"
		exit 56
	fi
echo "Checking whether /var/cache/zoneminder/images exists"
if [ "$(ls -Ad /var/cache/zoneminder/images)" ]; then
	 echo "... found /var/cache/zoneminder/images so not creating a new one"
else
	 echo "... didn't find /var/cache/zoneminder/images folder"
	 echo -n "... creating folder"
	 mkdir /var/cache/zoneminder/images
		if [ "$?" = "0" ]; then
		echo "OK"
		else
			echo "Failed"
			exit 57
		fi	 	
fi

echo -n "... changing ownership of the images folder recursively to www-data:www-data ... "
chown -R www-data:www-data "/var/cache/zoneminder/images"
	if [ "$?" = "0" ]; then
		echo "OK"
	else
		echo "Failed"
		exit 58
	fi

#Get docker env timezone and set system timezone
echo "setting the correct local time"
echo $TZ > /etc/timezone
export DEBCONF_NONINTERACTIVE_SEEN=true DEBIAN_FRONTEND=noninteractive
dpkg-reconfigure tzdata

echo "starting other services"
service apache2 start
service zoneminder start
