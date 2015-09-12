Linux + Nginx + Php-fpm + MySql Dev Environment for Magento, Symfony, Laravel and others
===============================

## What will be installed

* nginx - 1.8.0
* php - 5.5 with intl, mcrypt, pdo, curl, gd, sqlite, xmlrpc, xsl
* xhprof - (php profiler, for enable in project just add "xhprof" param to query string in url, example: http://myapp.loc?xhprof)
* percona-server - 5.5
* composer - latest
* git

## Ubuntu 14.04

#### Installation:

```bash
$ wget -nv -O - https://raw.githubusercontent.com/SergeyCherepanov/lnpm-env-dev/master/install-1404.sh | sudo bash
```

#### Usage:

For example we'll use *website.loc* hostname for project on local machine

1. Add `127.0.0.1 myapp.loc www.myapp.loc` to your /etc/hosts file
2. Put your source code to /var/www/loc/myapp, *web* (or *public*) folder will be resolved automatically by nginx
3. Project will be available by link: http://myapp.loc or http://www.myapp.loc

> note: for third level domain like dev.myapp.loc you should put code to /var/www/loc/dev.myapp folder

> mysql root password is: root

## Vagrant

#### Installation

Install VirtualBox https://www.virtualbox.org/wiki/Downloads

Install Vagrant from http://www.vagrantup.com/downloads

Install Vagrant plugins:

    $ vagrant plugin install vagrant-hostmanager

*Ubuntu/Debian Only:*

    $ sudo apt-get install nfs-kernel-server nfs-common

#### Usage

    $ git clone git@github.com:SergeyCherepanov/lnpm-env-dev.git
    $ cd lnpm-env-dev
    $ vagrant up

> Source code should be located in **www** folder

> Project will be available on: http://lnpm.loc

