# MediaWiki on Ubuntu

## Requirements

* [Ubuntu Server 16.04.4 LTS](https://www.ubuntu.com/download/server)

## Install

* Install Ubuntu Server 16.04.4 LTS
  * Do not install "LAMP server"
* Update Ubuntu: `sudo apt-get update && sudo apt-get upgrade`
* Install wget: `sudo apt-get install wget`
* Install MediaWiki-on-Ubuntu:
  * `wget https://github.com/rDuckDev/MediaWiki-on-Ubuntu/raw/master/install.sh`
  * `sudo sh isntall.sh`