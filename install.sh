#!/bin/bash

NoC="\033[0m"
RED="\033[0;31m"
GRN="\033[0;32m"
ORG="\033[0;33m"
BLU="\033[0;34m"

echo -e "${BLU}Installing MediaWiki${NoC}"
read -p "Enter the name of your wiki: " WIKI_NAME
echo
cd /var/www/html/
wget https://releases.wikimedia.org/mediawiki/1.35/mediawiki-1.35.2.tar.gz
tar -xvzf mediawiki-1.35.2.tar.gz
rm mediawiki-1.35.2.tar.gz
mv mediawiki-1.35.2 $WIKI_NAME

echo -e "${BLU}Installing MediaWiki extensions${NoC}"
read -p "Press any key to continue..." -n 1 -r
echo
# RevisionSlider https://www.mediawiki.org/wiki/Extension:RevisionSlider
echo -e "${BLU}RevisionSlider${NoC}"
cd /var/www/html/$WIKI_NAME/extensions
wget https://extdist.wmflabs.org/dist/extensions/RevisionSlider-REL1_35-d1a6af2.tar.gz
tar -xvzf RevisionSlider-REL1_35-d1a6af2.tar.gz
rm RevisionSlider-REL1_35-d1a6af2.tar.gz

echo -e "${BLU}Fixing file permissions${NoC}"
read -p "Press any key to continue..." -n 1 -r
echo
echo -e "${ORG}Please wait...${NoC}"
chown -R root:www-data /var/www/html/$WIKI_NAME
chown -R www-data:www-data /var/www/html/$WIKI_NAME/cache
chown -R www-data:www-data /var/www/html/$WIKI_NAME/images
find /var/www/html/$WIKI_NAME -type d -exec chmod 750 {} \;
find /var/www/html/$WIKI_NAME -type f -exec chmod 640 {} \;

echo -e "${BLU}Creating MariaDB database for MediaWiki${NoC}"
SYSOPPASS=`pwgen -syncB1 12`
USERPASS=`pwgen -syncB1 8`
while true
do
  read -s -p "MariaDB password for user root: " MariaDB_ROOT
  echo
  read -s -p "Confirm password for user root: " CONFIRM
  echo

  if [ "$CONFIRM" = "$MariaDB_ROOT" ]
  then
      mariadb -u root -p$MariaDB_ROOT -e "CREATE DATABASE $WIKI_NAME;"
      mariadb -u root -p$MariaDB_ROOT -e "GRANT ALL PRIVILEGES ON $WIKI_NAME.* TO 'wiki-sysop'@localhost IDENTIFIED BY '$SYSOPPASS';"
      mariadb -u root -p$MariaDB_ROOT -e "GRANT SELECT, INSERT, UPDATE, DELETE ON $WIKI_NAME.* TO 'wiki'@localhost IDENTIFIED BY '$USERPASS';"

      break
  else
      echo -e "${RED}Passwords did not match${NoC}"
  fi
done

# print config options
LOGFILE="/var/www/html/README"
IP_ADDR=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`

echo `date` > $LOGFILE
echo " " >> $LOGFILE
echo "MediaWiki API: http://$IP_ADDR/$WIKI_NAME/api.php" >> $LOGFILE
echo " " >> $LOGFILE
echo "Open your browser to http://$IP_ADDR/$WIKI_NAME to configure MediaWiki" >> $LOGFILE
echo " " >> $LOGFILE
echo "Database host: localhost" >> $LOGFILE
echo "Database name: $WIKI_NAME" >> $LOGFILE
echo "Database user: wiki-sysop" >> $LOGFILE
echo "Database pass: $SYSOPPASS" >> $LOGFILE
echo "Wiki name: $WIKI_NAME" >> $LOGFILE
echo " " >> $LOGFILE
echo "Add the following settings to LocalSettings.php" >> $LOGFILE
echo '$wgDBuser = "wiki";' >> $LOGFILE
echo '$wgDBpassword = "'$USERPASS'";' >> $LOGFILE
echo '$wgDBadminuser = "wiki-sysop";' >> $LOGFILE
echo '$wgDBadminpassword = "'$SYSOPPASS'";' >> $LOGFILE

echo -e "${ORG}The following was saved to $LOGFILE.${NoC}"
echo
cat /var/www/html/README
echo

echo -e "${GRN}Finished!${NoC}"
read -p "Press any key to continue..." -n 1 -r
echo
