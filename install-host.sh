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

echo -e "- How would you like to administer your machine?"
echo -e "  1) Cockpit"
echo -e "  2) Webmin"
echo -e "  3) SSH"
echo -e "  4) GUI"
echo -e "  5) None"
read -p "Option: " -n 1 -r
echo

case $REPLY in
  1 ) echo -e "- Installing Cockpit"
      apt-get install cockpit
      ;;
  2 ) echo -e "- Installing Webmin"
      cd /tmp
      wget http://prdownloads.sourceforge.net/webadmin/webmin_1.881_all.deb
      dpkg --install webmin_1.881_all.deb
      # dpkg might complain about dependencies,
      # so fix them and finish the installation
      apt-get -f install
      rm webmin_1.881_all.deb
      ;;
  3 ) echo -e "- Installing SSH"
      apt-get install openssh-server
      ;;
  4 ) echo -e "- Installing GUI"
      apt-get install --no-install-recommends ubuntu-desktop
      apt-get install firefox gedit
      ;;
  * ) echo
      ;;
esac

echo -e "Finished!"
read -p "Press any key to continue..." -n 1 -r
echo
