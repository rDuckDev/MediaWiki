#!/bin/bash

echo "Installing LAMP"
apt-get install apache2 libapache2-mod-php mysql-server php php-apcu php-cli php-curl php-intl php-mbstring php-mysql php-xml

echo "Installing required software"
apt-get install imagemagick wget unzip git nodejs npm

echo "Installing MediaWiki"
read -p "Enter the name of your wiki: " WIKI
cd /var/www/html/
wget https://releases.wikimedia.org/mediawiki/1.27/mediawiki-1.27.1.tar.gz
tar -xvzf mediawiki-1.27.1.tar.gz
rm mediawiki-1.27.1.tar.gz
mv mediawiki-1.27.1 $WIKI
chown -R www-data:www-data $WIKI
cd $WIKI

echo "Installing MediaWiki extensions"
cd extensions
# VisualEditor https://www.mediawiki.org/wiki/Extension:VisualEditor
wget https://github.com/rDuckDev/MediaWiki-on-Ubuntu/raw/master/VisualEditor.zip
unzip VisualEditor.zip
rm VisualEditor.zip
# RevisionSlider https://www.mediawiki.org/wiki/Extension:RevisionSlider
wget https://github.com/rDuckDev/MediaWiki-on-Ubuntu/raw/master/RevisionSlider.zip
unzip RevisionSlider.zip
rm RevisionSlider.zip

echo "Creating MySQL database for MediaWiki"
read -p "[MySQL][root] Password: " MySQL_ROOT
read -p "What would you like to name your MediaWiki database? " MySQL_DB
mysql -u root -p$MySQL_ROOT -e "CREATE DATABASE $MySQL_DB;"

echo "Creating MySQL user for MediaWiki"
read -p "Username: " MySQL_USER
read -p "Password: " MySQL_PASS
mysql -u root -p$MySQL_ROOT -e "GRANT ALL PRIVILEGES ON $MySQL_DB.* TO $MySQL_USER@localhost IDENTIFIED BY '$MySQL_PASS';"

echo "Securing MySQL"
mysql_secure_installation

echo "Installing Parsoid"
cd /usr/bin/
git clone https://github.com/wikimedia/parsoid.git -b v0.5.1
cd parsoid
npm install

echo "You must configure the Parsoid uri"
echo "IP address:"
ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'
echo "Wiki name:"
echo $WIKI
read -p "Press enter to continue..." BURN
cp localsettings.js.example localsettings.js
vi localsettings.js

echo "Registering the Parsoid service"
cd /etc/systemd/system
wget https://github.com/rDuckDev/MediaWiki-on-Ubuntu/raw/master/parsoid.service
chmod 777 parsoid.service
chown root:root parsoid.service
systemctl daemon-reload
systemctl enable parsoid
systemctl start parsoid

echo "Installing Webmin"
mkdir /temp
cd /temp
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.881_all.deb
dpkg --install webmin_1.881_all.deb
# dpkg might complain about dependencies,
# so fix them and finish installation
apt-get -f install

echo "Configure MediaWiki using your web browser"
echo "Use Webmin (http://yourIP:10000) to place LocalSettings.php in /var/www/html/$WIKI"

echo "Finished!"
read -p "Press enter to continue..." BURN