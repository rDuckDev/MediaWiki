#!/bin/bash

read -p "Enter the name of your wiki: " WIKI_NAME

echo "Clearing pending jobs"
cd /var/www/html/$WIKI_NAME/maintenance
php runJobs.php --quiet --nothrottle

echo "Backing up MySQL database"
while true
do
	read -p "MySQL password for user root: " MySQL_ROOT
	read -p "Confirm password for user root: " CONFIRM

	if [ "$CONFIRM" = "$MySQL_ROOT" ]
	then
		rm $WIKI_NAME.sql # remove SQL dump if old one exists
		mysqldump --user=root --password=$MySQL_ROOT $WIKI_NAME > /var/www/html/$WIKI_NAME.sql

		break
	else
		echo "Passwords did not match"
	fi
done

echo "Downloading MediaWiki"
cd /var/www/html/
wget https://releases.wikimedia.org/mediawiki/1.27/mediawiki-1.27.4.tar.gz
tar -xvzf mediawiki-1.27.4.tar.gz
rm -f mediawiki-1.27.4.tar.gz
cp -R -f mediawiki-1.27.4/* $WIKI_NAME
rm -rf mediawiki-1.27.4
chown -R www-data:www-data $WIKI_NAME
cd $WIKI_NAME/maintenance
php update.php

echo "Finished!"