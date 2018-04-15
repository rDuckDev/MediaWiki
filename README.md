# MediaWiki on Ubuntu

## Requirements

* [Ubuntu Server 16.04.4 LTS](https://www.ubuntu.com/download/server)

## Versions

* MediaWiki 1.27.1 LTS
  * Upgrade 1.27.4 LTS
* Parsoid 0.5.1 for 1.27

## Install-Host.sh

* Install Ubuntu Server 16.04.4 LTS
  * Do not install "LAMP server"
* Update Ubuntu: `sudo apt-get update && sudo apt-get upgrade`
* Install wget: `sudo apt-get install wget`
* Install LAMP, required software and admin tools
  * `wget https://github.com/rDuckDev/MediaWiki-on-Ubuntu/raw/master/install-host.sh`
  * `sudo sh install-host.sh`

## Install.sh

* Install MediaWiki on Ubuntu:
  * `wget https://github.com/rDuckDev/MediaWiki-on-Ubuntu/raw/master/install.sh`
  * `sudo sh isntall.sh`
  * Note: Parsoid defaults to port 8000, but 8142 is recommended
* Configure MediaWiki using your browser
  * Download LocalSettings.php and add / update the following lines:
    ```php
    ## Database settings
    $wgDBuser = "wiki"
    $wgDBpassword = "<output from README>"
    $wgDBadminuser = "wiki-sysop"
    $wgDBadminpassword = "<output from README>"
    # Configure MultimediaViewer
    $wgDefaultUserOptions['multimediaviewer-enable'] = 1;
    # Configure VisualEditor
    $wgDefaultUserOptions['visualeditor-enable'] = 1;
    $wgDefaultUserOptions['usebetatoolbar'] = 1;
    $wgHiddenPrefs[] = 'visualeditor-enable';
    $wgVirtualRestConfig['modules']['parsoid']['url'] = "http://ParsoidURL:8142";
    ```
  * Upload LocalSettings.php to /var/www/html/WikiName

## Update.sh

**Important:** Backup your MySQL wiki DB and /var/www/html/WikiName first

* Update MediaWiki-on-Ubuntu:
  * `wget https://github.com/rDuckDev/MediaWiki-on-Ubuntu/raw/master/update.sh`
  * `sudo sh update.sh`
* Update LocalSettings.php
  * Change `$wgMainCacheType=CACHE_NONE` to `$wgMainCacheType=CACHE_ACCEL` if necessary

## Notes

* What's installed?
  * Apache
  * MySQL
  * PHP
  * ImageMagick
  * Git
  * Node.js
  * NPM
  * Composer
  * Remote admin (one)
    * [Cockpit](http://cockpit-project.org/)
    * [Webmin](https://doxfer.webmin.com/Webmin/Main_Page)
    * [OpenSSH](http://www.openssh.com/)
* Useful links
  * [MediaWiki maintenance](https://doc.wikimedia.org/mediawiki-core/master/php/group__Maintenance.html)
  * [PHP security tips](https://www.cyberciti.biz/tips/php-security-best-practices-tutorial.html)
