![Vagrant](https://img.shields.io/badge/vagrant-box-brightgreen.svg?style=flat-square) [![License MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://opensource.org/licenses/MIT)

# Vagrant LEMP Box
Rock-solid Debian based Vagrant box with a straightforward LEMP configuration. No Puppet or Chef knowledge required. 
Easy to extend with basic bash knowledge.

## Stack
- Debian Jessie
- nginx 1.6
- PHP 5.6 (curl, FPM, GD, GMP, Imagick, intl, LDAP, Mcrypt, MySQL, PEAR, PECL, pspell, Recode, SQLite, Tidy, Xdebug, XSL)
- MariaDB 10.0

## Requirements
- VirtualBox
- Vagrant

## Usage
1. Clone Git repository
2. Choose app in Vagrantfile or start from "scratch"
3. Define document root in Vagrantfile
4. Run "vagrant up"
5. Create fantastic things!

### Supported Apps

- Drupal
- Laravel
- Magento
- Symfony
- TYPO3
- WordPress

### Database
You need a database? These box creates one for you:
Host: `localhost`, DB: `vagrant`, User: `vagrant`, Password: `vagrant`

## Extending

In the file `vagrant/30_custom.sh` is space for your improvements.