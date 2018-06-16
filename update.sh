#!/bin/bash

NoC="\033[0m"
RED="\033[0;31m"
GRN="\033[0;32m"
ORG="\033[0;33m"
BLU="\033[0;34m"

echo -e "${BLU}Upgrading MediaWiki${NoC}"
read -p "Enter the name of your wiki: " WIKI_NAME
echo

echo -e "${BLU}Clearing pending jobs${NoC}"
cd /var/www/html/$WIKI_NAME/maintenance
php runJobs.php --quiet --nothrottle

echo -e "${BLU}Making your wiki read-only${NoC}"
cd /var/www/html/$WIKI_NAME
cp LocalSettings.php LocalSettings.php.bak
echo >> LocalSettings.php # make sure $wgReadOnly is on a new line
echo '$wgReadOnly = "This wiki is currently being upgraded to a newer software version.";' >> LocalSettings.php
echo

echo -e "${BLU}Backing up MySQL database${NoC}"
while true
do
	read -s -p "MySQL password for user root: " MySQL_ROOT
	echo
	read -s -p "Confirm password for user root: " CONFIRM
	echo

	if [ "$CONFIRM" = "$MySQL_ROOT" ]
	then
		mysqldump --user=root --password=$MySQL_ROOT $WIKI_NAME > /var/www/html/$WIKI_NAME.sql

		break
	else
		echo -e "${RED}Passwords did not match${NoC}"
	fi
done

echo -e "${BLU}Upgrading Parsoid${NoC}"
service parsoid stop
cd /usr/lib/
cp ./parsoid/localsettings.js /tmp/localsettings.js.bak
rm -rf parsoid
git clone https://github.com/wikimedia/parsoid.git --branch v0.9.0 --depth 1 parsoid
cd parsoid
npm install
cp config.example.yaml config.yaml
mv /tmp/localsettings.js.bak ./localsettings.js.old
echo -e "${BLU}Opening the new Parsoid configuration for editing${NoC}"
echo -e "${ORG}The previous settings are saved in /usr/lib/parsoid/localsettings.js.bak${NoC}"
read -p "Press any key to continue..." -n 1 -r
echo
vi config.yaml
service parsoid start

echo -e "${BLU}Downloading MediaWiki${NoC}"
cd /var/www/html/
wget https://releases.wikimedia.org/mediawiki/1.31/mediawiki-1.31.0.tar.gz
tar -xvzf mediawiki-1.31.0.tar.gz
rm mediawiki-1.31.0.tar.gz
mv mediawiki-1.31.0 new_$WIKI_NAME

echo -e "${BLU}Installing MediaWiki extensions${NoC}"
# VisualEditor https://www.mediawiki.org/wiki/Extension:VisualEditor
echo -e "${BLU}VisualEditor${NoC}"
cd /var/www/html/new_$WIKI_NAME/extensions
git clone https://github.com/wikimedia/mediawiki-extensions-VisualEditor.git --branch REL1_31 --depth 1 VisualEditor
cd VisualEditor
git submodule update --init
# RevisionSlider https://www.mediawiki.org/wiki/Extension:RevisionSlider
echo -e "${BLU}RevisionSlider${NoC}"
cd /var/www/html/new_$WIKI_NAME/extensions
git clone https://github.com/wikimedia/mediawiki-extensions-RevisionSlider.git --branch REL1_31 --depth 1 RevisionSlider
cd RevisionSlider
composer install --no-dev
npm install

echo -e "${BLU}Checking for persistent files${NoC}"
cd /var/www/html
PERSIST="persist.txt"
if [ ! -f $PERSIST ]
then
	echo "./LocalSettings.php" > $PERSIST
	echo "./images" >> $PERSIST
	echo
	echo -e "${BLU}Opening the list of files which will persist through the update"
	echo -e "Please add any files or directories which are not already listed${NoC}"
	read -p "Press any key to continue..." -n 1 -r
	echo
	vi $PERSIST
fi

# this must happen before files are moved,
# otherwise read-only will persists
echo -e "${BLU}Disable read-only for your wiki${NoC}"
cd /var/www/html/$WIKI_NAME
mv LocalSettings.php.bak LocalSettings.php

echo -e "${BLU}Moving persistent files${NoC}"
cd /var/www/html
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

echo -e "${BLU}Switching to the new wiki${NoC}"
cd /var/www/html/
mv $WIKI_NAME old_$WIKI_NAME
mv new_$WIKI_NAME $WIKI_NAME

echo -e "${BLU}Fixing file permissions${NoC}"
chown -R root:www-data /var/www/html/$WIKI_NAME
chown -R www-data:www-data /var/www/html/$WIKI_NAME/cache
chown -R www-data:www-data /var/www/html/$WIKI_NAME/images
find /var/www/html/$WIKI_NAME -type d -exec chmod 750 {} \;
find /var/www/html/$WIKI_NAME -type f -exec chmod 640 {} \;

echo -e "${BLU}Updating MediaWiki${NoC}"
cd /var/www/html/$WIKI_NAME/maintenance
php update.php

echo -e "${GRN}Finished!${NoC}"
read -p "Press any key to continue..." -n 1 -r
echo
