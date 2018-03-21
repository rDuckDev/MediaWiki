#!/bin/bash

printf "Installing LAMP stack\n\n"
apt-get install apache2 libapache2-mod-php mysql-server php php-apcu php-cli php-curl php-intl php-mbstring php-mysql php-xml


printf "Installing required software\n\n"
apt-get install imagemagick wget unzip git nodejs npm cockpit

printf "Configuring MySQL for MediaWiki\n\n"
mysql_secure_installation

printf "Enter the following commands"
printf "CREATE DATABASE WikiDB;"
printf "GRANT ALL PRIVILEGES ON WikiDB.* TO wiki@'localhost' IDENTIFIED BY '<password>';\n\n"
mysql -u root -p

printf "Configuring MediaWiki\n\n"
cd /var/www/html/
wget https://releases.wikimedia.org/mediawiki/1.27/mediawiki-1.27.1.tar.gz
tar -xvzf mediawiki-1.27.1.tar.gz
rm mediawiki-1.27.1.tar.gz
mv mediawiki-1.27.1 InternalIndex
cd InternalIndex
chown -R www-data images

printf "Configuring MediaWiki extensions\n\n"
cd extensions
wget https://github.com/rDuckDev/MediaWiki/raw/master/VisualEditor.zip
unzip VisualEditor.zip
rm VisualEditor.zip
wget https://github.com/rDuckDev/MediaWiki/raw/master/RevisionSlider.zip
unzip RevisionSlider.zip
rm RevisionSlider.zip

printf "Configuring Parsoid\n\n"
cd /usr/bin/
git clone https://github.com/wikimedia/parsoid.git -b v0.5.1
cd parsoid
npm install
cp localsettings.js.example localsettings.js
vi localsettings.js
cd /etc/systemd/system
wget https://github.com/rDuckDev/MediaWiki/raw/master/parsoid.service
chmod 777 parsoid.service
chown root:root parsoid.service
systemctl daemon-reload
systemctl enable parsoid
system start parsoid