#!/bin/bash
# only for Ubuntu/Debian

ROOT=/www

if [[ $1 == initdb ]]; then
	sudo -u postgres psql -f ./init.sql
elif [[ $1 == install-theme ]]; then
	cd $ROOT/ttrss/themes;
	wget https://github.com/levito/tt-rss-feedly-theme/archive/master.zip &&
		unzip -q master.zip && rm -f master.zip && cd tt-rss-feedly-theme-master &&
		rm -rf feedly-screenshots README.md &&
		chmod 755 -R * && chown www-data:www-data * &&
		cd .. && mv tt-rss-feedly-theme-master/* . && 
		rm -rf tt-rss-feedly-theme-master
else
	cd ~
	sudo apt-get update
	apt-get install unzip vim -y
	sudo apt-get install php5 php5-pgsql php5-fpm php-apc php5-curl php5-cli -y
	sudo apt-get install postgresql -y
	#sudo apt-get install nginx -y && sudo service nginx start

	if [ ! -d $ROOT/ttrss ]; then
		[ -f archive.zip ] || wget https://tt-rss.org/gitlab/fox/tt-rss/repository/archive.zip && unzip -q archive.zip
		[ -d $ROOT ] || mkdir $ROOT && mv tt-rss.git $ROOT/ttrss
		sudo chown -R www-data:www-data $ROOT
	fi
fi
