#!/bin/bash

NoC="\033[0m"
RED="\033[0;31m"
GRN="\033[0;32m"
ORG="\033[0;33m"
BLU="\033[0;34m"

echo -e "${BLU}Installing LAMP stack${NoC}"
read -p "Press any key to continue..." -n 1 -r
apt-get install apache2 libapache2-mod-php mysql-server php php-apcu php-cli php-curl php-intl php-mbstring php-mysql php-xml

echo -e "${BLU}Installing required software${NoC}"
read -p "Press any key to continue..." -n 1 -r
cd /tmp
apt-get install imagemagick wget zip unzip git nodejs npm pwgen
wget https://getcomposer.org/installer
php installer --filename=composer --install-dir=/bin

echo -e "${BLU}Securing MySQL${NoC}"
read -p "Press any key to continue..." -n 1 -r
mysql_secure_installation

echo -e "${BLU}How would you like to administer your machine?"
echo -e "  1) Cockpit"
echo -e "  2) Webmin"
echo -e "  3) SSH"
echo -e "  4) GUI"
echo -e "  5) None${NoC}"
read -p "Option: " -n 1 -r
echo

case $REPLY in
  1 ) echo -e "${BLU}Installing Cockpit${NoC}"
      apt-get install cockpit
      ;;
  2 ) echo -e "${BLU}Installing Webmin${NoC}"
      cd /tmp
      wget http://prdownloads.sourceforge.net/webadmin/webmin_1.881_all.deb
      dpkg --install webmin_1.881_all.deb
      # dpkg might complain about dependencies,
      # so fix them and finish the installation
      apt-get -f install
      rm webmin_1.881_all.deb
      ;;
  3 ) echo -e "${BLU}Installing SSH${NoC}"
      apt-get install openssh-server
      ;;
  4 ) echo -e "${BLU}Installing GUI${NoC}"
      apt-get install --no-install-recommends ubuntu-desktop
      apt-get install firefox gedit
      ;;
  * ) echo -e ""
      ;;
esac

echo -e "${GRN}Finished!${NoC}"
read -p "Press any key to continue..." -n 1 -r
