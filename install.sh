#!/bin/bash

echo "Installing MediaWiki LTS"
read -p "Enter the name of your wiki: " WIKI
cd /var/www/html/
wget https://releases.wikimedia.org/mediawiki/1.27/mediawiki-1.27.4.tar.gz
tar -xvzf mediawiki-1.27.4.tar.gz
rm mediawiki-1.27.4.tar.gz
mv mediawiki-1.27.4 $WIKI
chown -R www-data:www-data $WIKI
cd $WIKI

echo "Installing MediaWiki extensions"
cd extensions
# VisualEditor https://www.mediawiki.org/wiki/Extension:VisualEditor
wget https://extdist.wmflabs.org/dist/extensions/VisualEditor-REL1_27-9da5996.tar.gz
tar -xvzf VisualEditor-REL1_27-9da5996.tar.gz
rm VisualEditor-REL1_27-9da5996.tar.gz
# RevisionSlider https://www.mediawiki.org/wiki/Extension:RevisionSlider
wget https://extdist.wmflabs.org/dist/extensions/RevisionSlider-REL1_27-c980a0c.tar.gz
tar -xvzf RevisionSlider-REL1_27-c980a0c.tar.gz
rm RevisionSlider-REL1_27-c980a0c.tar.gz

echo "Creating MySQL database for MediaWiki"
read -p "What would you like to name the database? " MySQL_DB
while true
do
	read -p "MySQL password: " MySQL_ROOT
	read -p "Confirm password: " CONFIRM

	if [ "$CONFIRM" = "$MySQL_ROOT" ]
	then
		mysql -u root -p$MySQL_ROOT -e "CREATE DATABASE $MySQL_DB;"

		echo "Creating a new MySQL user for MediaWiki"
		read -p "Username: " MySQL_USER
		while true
		do
			read -p "Password: " MySQL_PASS
			read -p "Confirm: " CONFIRM

			if [ "$CONFIRM" = "$MySQL_PASS" ]
			then
				mysql -u root -p$MySQL_ROOT -e "GRANT ALL PRIVILEGES ON $MySQL_DB.* TO '$MySQL_USER'@localhost IDENTIFIED BY '$MySQL_PASS';"
				break
			else
				echo "Passwords did not match"
			fi
		done

		break
	else
		echo "Passwords did not match"
	fi
done

echo "Installing Parsoid"
cd /usr/lib/
# Parsoid 0.5.1 was the last version to work with MW 1.27 branch
git clone https://github.com/wikimedia/parsoid.git -b v0.5.1
cd parsoid
npm install

echo "You must configure the Parsoid uri"
read -p "Press enter to open the config file for editing..." BURN
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

echo "Finished!"

read -p "Press enter to continue..." BURN
