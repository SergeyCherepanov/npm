#!/usr/bin/env bash
DIR=$(dirname $(readlink -f $0))
TMPDIR=/tmp/npm

export DEBIAN_FRONTEND=noninteractive
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

while [[ $# > 1 ]]
do
key="$1"
case ${key} in
    --www-root)
    WWW_ROOT="$2"
    shift
    ;;
    --www-user)
    WWW_USER="$2"
    shift
    ;;
    --www-group)
    WWW_GROUP="$2"
    shift
    ;;
    *)
    # unknown option
    ;;
esac
shift
done

[[ -z ${WWW_ROOT}  ]] && WWW_ROOT="/var/www"
[[ -z ${WWW_USER}  ]] && WWW_USER="www-data"
[[ -z ${WWW_GROUP} ]] && WWW_GROUP="www-data"

DEBCONF_PREFIX="mysql-server-5.6 mysql-server"
MYSQL_PW="root"

echo "${DEBCONF_PREFIX}/root_password password $MYSQL_PW" | debconf-set-selections
echo "${DEBCONF_PREFIX}/root_password_again password $MYSQL_PW" | debconf-set-selections

locale-gen en_US.UTF-8
dpkg-reconfigure locales 

# Clean tmp dir
if [ -d ${TMPDIR} ]; then
    rm -rf ${TMPDIR}
fi

mkdir -p ${TMPDIR}

# Repository tools
apt-get update
apt-get install -qqy software-properties-common python-software-properties

# Nginx repo
add-apt-repository -y ppa:nginx/stable

# Php repo
add-apt-repository -y ppa:ondrej/php

# Node.js repo
curl -sL https://deb.nodesource.com/setup_4.x | bash -

# Update
apt-get update
apt-get -y upgrade

# Install Mysql-Server
apt-get -q -y install mysql-server-5.6 mysql-client-5.6

# Install tools
apt-get install -qqy unzip git-core curl wget htop screen mc mtr-tiny apache2-utils

# Install nginx
apt-get install -qqy nginx

# Install php 5.6
apt-get install -qqy php5.6-cli php5.6-dev \
php5.6-mysql php5.6-curl php5.6-gd php5.6-mcrypt php5.6-sqlite php5.6-xmlrpc php5.6-ldap \
php5.6-xsl php5.6-common php5.6-intl php5.6-soap php5.6-mbstring php5.6-zip php5.6-bz2 php5.6-cli php5.6-fpm

# Install mail tools
apt-get install -qqy opendkim opendkim-tools

# Install IonCube
wget -O ${TMPDIR}/ioncube.tgz "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_"$([[ "x86_64" = `arch` ]] && echo "x86-64" || [[ "armv7l" = `arch` ]] && echo "armv7l" || echo "x86")".tar.gz"
tar xvzf ${TMPDIR}/ioncube.tgz -C ${TMPDIR}
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
PHP_EXTDIR=$(php -i | grep "^extension_dir" | awk '{print $3}')
[[ ! -d ${PHP_EXTDIR} ]] && echo "Extension dir '${EXTDIR}' not found!" && exit 1
cp "${TMPDIR}/ioncube/ioncube_loader_lin_${PHP_VERSION}.so" ${PHP_EXTDIR}
echo "zend_extension = ${PHP_EXTDIR}/ioncube_loader_lin_${PHP_VERSION}.so" > /etc/php/5.6/mods-available/ioncube.ini
ln -s /etc/php/5.6/mods-available/ioncube.ini /etc/php/5.6/cli/conf.d/0-ioncube.ini
ln -s /etc/php/5.6/mods-available/ioncube.ini /etc/php/5.6/fpm/conf.d/0-ioncube.ini

# Enabling mcrypt
php5enmod mcrypt

# Install Ruby + Ruby Compass + Sass
apt-get install -qqy ruby ruby-dev

# Install Ruby Compass + Sass
gem install compass

# Install Node.js
apt-get install -qqy nodejs

# Install less compiler
apt-get install -qqy node-less yui-compressor

# Install composer
php -r "readfile('https://getcomposer.org/installer');" | php
mv composer.phar /usr/local/bin/composer.phar
ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Resolve environment configs
if [ -d ${DIR}/conf ]; then
    cp -r ${DIR}/conf ${TMPDIR}/conf
    cd ${TMPDIR}
else
    wget -O /tmp/conf.zip https://github.com/SergeyCherepanov/npm/archive/master.zip
    unzip /tmp/conf.zip -d ${TMPDIR}
    rm /tmp/conf.zip
    cd ${TMPDIR}/$(ls -1 ${TMPDIR}/ | grep npm-master | head -1)
fi

# Prepare environment configs
# --------------------
mv ./conf/nginx/sites-available/*       /etc/nginx/sites-available/
mv ./conf/nginx/status.inc              /etc/nginx/status.inc
mv ./conf/mysql/my.cnf                  /etc/mysql/my.cnf
mv ./conf/php/php.ini                   /etc/php/5.6/fpm/php.ini

sed -i -e "s/\s*set\s\s*\$wwwRoot\s\s*\/var\/www\;/    set \$wwwRoot "$(echo ${WWW_ROOT} | sed -e 's/[\.\:\/&]/\\&/g')";/g" /etc/nginx/sites-available/default
sed -i -e "s/\s*user\s\s*.*\;/user ${WWW_USER};/g"                  /etc/nginx/nginx.conf
sed -i -e "s/\s*user\s*=\s*.*/user=${WWW_USER}/g"                   /etc/php/5.6/fpm/pool.d/www.conf
sed -i -e "s/\s*group\s*=\s*.*/group=${WWW_GROUP}/g"                /etc/php/5.6/fpm/pool.d/www.conf
sed -i -e "s/\s*listen.owner\s*=.*/listen.owner = ${WWW_USER}/g"    /etc/php/5.6/fpm/pool.d/www.conf
sed -i -e "s/\s*listen.group\s*=.*/listen.group = ${WWW_GROUP}/g"   /etc/php/5.6/fpm/pool.d/www.conf
sed -i -e "s/.*pm.status_path\s*=.*/pm.status_path = /fpm_status/g" /etc/php/5.6/fpm/pool.d/www.conf
sed -i -e "s/.*ping.path\s*=.*/ping.path = /fpm_ping/g"             /etc/php/5.6/fpm/pool.d/www.conf

rm /var/lib/mysql/ibdata1
rm /var/lib/mysql/ib_logfile0
rm /var/lib/mysql/ib_logfile1

[[ ! -d ${WWW_ROOT} ]] && mkdir -p ${WWW_ROOT}
[[ ! -f ${WWW_ROOT}/index.php ]] && echo "<?php phpinfo();" > ${WWW_ROOT}/index.php

HTPASSWORD=`dd if=/dev/urandom bs=128 count=1 2>/dev/null | LC_ALL=C tr -dc 'a-z0-9' | fold -w 16 | head -n 1 | awk '{print tolower($0)}'`

chown -R ${WWW_USER}:${WWW_GROUP} ${WWW_ROOT}

echo "${WWW_USER}:${HTPASSWORD}" > /etc/nginx/.htpasswd-plain
htpasswd -bc /etc/nginx/.htpasswd ${WWW_USER} ${HTPASSWORD}

# Restart service
if [[ 0 -lt `ps aux | grep upstart | grep -v grep | wc -l` ]]
then
    service nginx restart
    service php5.6-fpm restart
    service mysql restart
fi

# Cleanup
# rm -rf $TMPDIR
