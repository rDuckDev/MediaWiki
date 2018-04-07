#!/bin/bash

echo "Please take a backup of /var/www/html/WikiName and your MySQL database first!"
read -p "Enter the name of your wiki: " WIKI_NAME

echo "Clearing pending jobs"
cd /var/www/html/$WIKI_NAME/maintenance
php runJobs.php --quiet --nothrottle

echo "Updating MediaWiki"
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