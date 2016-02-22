![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)

# vagrant-box
Rock-solid Debian based Vagrant box with a straightforward LEMP configuration. No Puppet or Chef knowledge required. Easy to extend with basic bash knowledge.

## Features
- Debian Jessie
- nginx
- PHP 5.6
- MariaDB

## Requirements
- VirtualBox
- Vagrant

## Usage
- Clone Git repository
- Choose app in Vagrantfile
- Run "vagrant up"

## XDebug Setup for PHPStorm
- Enable xdebug in Vagrantfile
- Go to preferences and search for servers under PHP section
- Add new server with the host of the vagrant box
- Select checkbox "Use path mappings ..."
- Set Absolute path on server to /var/www
- Go to Run/Debug Configurations -> PHP Remote Debug
- Select the created server
- Set Ide Key to vagrant
- Start listening for debug connections by clicking the debug icon in PHPStorm.