#!/bin/bash

# This script installs the LAMP stack onto Ubuntu,
# along with several packages required by MediaWiki.

echo -e "- Installing LAMP stack"
echo

debconf-apt-progress -- apt-get install -y \
	apache2 libapache2-mod-php \
	php php-apcu php-cli php-curl php-intl php-mbstring php-mysql php-xml \
	imagemagick wget zip unzip git nodejs npm pwgen \
	mysql-server
mysql_secure_installation
echo

echo -e "How would you like to administer your machine? [1-5]"
echo -e "  1) Cockpit"
echo -e "  2) Webmin"
echo -e "  3) OpenSSH"
echo -e "  4) GUI"
echo -e "  5) None"
read -p "Option: " -n 1 -r
echo

case $REPLY in
	1 ) echo -e "- Installing Cockpit"
		echo
		debconf-apt-progress -- apt-get install -y cockpit
		;;
	2 ) echo -e "- Installing Webmin"
		echo
		wget -c http://prdownloads.sourceforge.net/webadmin/webmin_1.910_all.deb \
			-q --show-progress -O /tmp/webmin.deb
		dpkg --install /tmp/webmin.deb
		# dpkg might complain about dependencies,
		# so fix them and finish the installation
		apt-get -f install -y
		;;
	3 ) echo -e "- Installing OpenSSH"
		echo
		debconf-apt-progress -- apt-get install -y openssh-server
		;;
	4 ) echo -e "- Installing GUI"
		echo
		debconf-apt-progress -- apt-get install -y --no-install-recommends \
			ubuntu-desktop firefox gedit
		;;
	* ) echo
		;;
esac

echo -e "- Installation complete"
echo

read -p "All done!"
echo
