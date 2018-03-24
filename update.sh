#!/bin/bash

read -p "Enter the name of your wiki: " WIKI

echo "Clearing pending jobs"
cd /var/www/html/$WIKI/maintenance
php runJobs.php

echo "Updating MediaWiki"
cd /var/www/html/
wget https://releases.wikimedia.org/mediawiki/1.27/mediawiki-1.27.4.tar.gz
tar -xvzf mediawiki-1.27.4.tar.gz
rm -f mediawiki-1.27.4.tar.gz
cp -R -f mediawiki-1.27.4/* $WIKI
rm -rf mediawiki-1.27.4
chown -R www-data:www-data $WIKI
cd $WIKI/maintenance
php update.php

echo "Finished!"