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
mv mediawiki-1.27.4 new_$WIKI_NAME

echo "Checking for persistent files"
PERSIST="persist.txt"
if [ ! -f $PERSIST ]
then
	echo "./LocalSettings.php" > $PERSIST
	echo "./images" >> $PERSIST
	echo "./extensions/VisualEditor" >> $PERSIST
	echo "./extensions/RevisionSlider" >> $PERSIST
	echo " "
	echo "Opening the list of files which will persist through the update"
	echo "Please add any files or directories which are not already listed"
	read -p "Press enter to edit the file..." BURN
	vi $PERSIST
fi

echo "Moving persistent files"
while read -r LINE
do
	# if the directory already exists, then the replacing directory
	# will actually nest itself inside the existing directory
	if [ -d ./new_$WIKI_NAME/$LINE ]
	then
		rm -rf ./new_$WIKI_NAME/$LINE
	fi
	# files were sometimes behaving like directories if they didn't have an extension,
	# so they're removed as well
	if [ -f ./new_$WIKI_NAME/$LINE ]
	then
		rm -rf ./new_$WIKI_NAME/$LINE
	fi
	
	cp -fR ./$WIKI_NAME/$LINE ./new_$WIKI_NAME/$LINE
done < $PERSIST

echo "Updating MediaWiki"
cd new_$WIKI_NAME/maintenance
php update.php

echo "Switching to the new wiki"
cd /var/www/html/
mv $WIKI_NAME old_$WIKI_NAME
mv new_$WIKI_NAME $WIKI_NAME

echo "Fixing file permissions"
chown -R www-data:www-data $WIKI_NAME

echo "Finished!"
