#!/bin/bash

echo "Installing LAMP"
apt-get install apache2 libapache2-mod-php mysql-server php php-apcu php-cli php-curl php-intl php-mbstring php-mysql php-xml

echo "Installing required software"
apt-get install imagemagick wget zip unzip git nodejs npm pwgen

echo "Securing MySQL"
mysql_secure_installation

echo "How would you like to administer your machine?"
echo "  1) Cockpit"
echo "  2) Webmin"
echo "  3) SSH"
echo "  4) None"
read -p "Option: " OPTION

case $OPTION in
	1 )	echo "Installing Cockpit"
		apt-get install cockpit
		;;
	2 ) echo "Installing Webmin"
		cd /tmp
		wget http://prdownloads.sourceforge.net/webadmin/webmin_1.881_all.deb
		dpkg --install webmin_1.881_all.deb
		# dpkg might complain about dependencies,
		# so fix them and finish installation
		apt-get -f install
		rm webmin_1.881_all.deb
		;;
	3 ) echo "Installing SSH"
		apt-get install openssh-server
		;;
	* ) echo ""
		;;
esac

echo "Finished!"

read -p "Press enter to continue..." BURN
