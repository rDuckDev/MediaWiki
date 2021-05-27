# MediaWiki KMS

A collection of resources that help to install MediaWiki as a knowledge management system (KMS).

## Versions

* [Ubuntu Server 18.04.2 LTS](https://www.ubuntu.com/download/server)
* MediaWiki 1.31.0 LTS
* Parsoid 0.9.0 for REL1_31

## Installation

* Install Ubuntu Server
  * Do not install "LAMP server"
* Install updates and patches
  ```bash
  sudo su
  apt-get update && apt-get dist-upgrade -y
  ```

### install-host

* Install LAMP stack and required software
  ```bash
  cd /tmp
  sudo su
  apt-get install wget
  wget https://github.com/rDuckDev/MediaWiki-KMS/raw/master/install-host
  bash install-host
  ```

## Install.sh

* Install MediaWiki on Ubuntu:
  * `wget https://github.com/rDuckDev/MediaWiki-KMS/raw/master/install.sh`
  * `sudo bash install.sh`
  * Note: Parsoid defaults to port 8000, but 8142 is recommended on Ubuntu / Debian
* Configure MediaWiki using your browser
  * Download LocalSettings.php and add (or update) the following lines:
    ```php
    ## Database settings
    $wgDBuser = "wiki";
    $wgDBpassword = "<output from README>";
    $wgDBadminuser = "wiki-sysop";
    $wgDBadminpassword = "<output from README>";
    # Configure MultimediaViewer
    $wgDefaultUserOptions['multimediaviewer-enable'] = 1;
    # Configure WikiEditor and CodeEditor
    $wgDefaultUserOptions['usebetatoolbar'] = 1;
    # Configure VisualEditor
    $wgVisualEditorEnableDiffPage = true;
    $wgVisualEditorEnableWikitext = true;
    $wgDefaultUserOptions['visualeditor-enable'] = 1;
    $wgHiddenPrefs[] = 'visualeditor-enable';
    $wgVisualEditorAvailableNamespaces = [
        "User" => true,
        "Help" => true
    ];
    $wgVirtualRestConfig['modules']['parsoid']['url'] = "http://ParsoidURL:8142";
    ```
  * Upload LocalSettings.php to /var/www/html/WikiName

## Update.sh

* Update MediaWiki-KMS:
  * `wget https://github.com/rDuckDev/MediaWiki-KMS/raw/master/update.sh`
  * `sudo bash update.sh`
* Update LocalSettings.php

## Notes

### Software

* Apache
* MySQL
* PHP
* ImageMagick
* Git
* Node.js
* NPM
* Admin (one)
  * [Cockpit](http://cockpit-project.org/)
  * [Webmin](https://doxfer.webmin.com/Webmin/Main_Page)
  * OpenSSH
  * GUI (minimal)
    * Firefox
    * gedit

### Useful links

* [MediaWiki maintenance](https://doc.wikimedia.org/mediawiki-core/master/php/group__Maintenance.html)
* [PHP security tips](https://www.cyberciti.biz/tips/php-security-best-practices-tutorial.html)
* [MySQL performance tips](https://www.percona.com/blog/2014/01/28/10-mysql-performance-tuning-settings-after-installation/)
