#!/bin/bash

echo "============================================"
echo "mssql-tools"
echo "============================================"

# curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
apt-get update
apt-get -y install msodbcsql17 mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
apt-get -y install unixodbc-dev

echo "============================================"
echo "crontab"
echo "============================================"

# 安装计划任务
apt-get -y install cron

echo "============================================"
echo "Building extensions for 1:$PHP_VERSION 2:$PHP_XDEBUG 3:$PHP_SWOOLE 4:$PHP_REDIS"
echo "============================================"

function phpVersion() {
    [[ ${PHP_VERSION} =~ ^([0-9]+)\.([0-9]+)\.([0-9]+) ]]
    num1=${BASH_REMATCH[1]}
    num2=${BASH_REMATCH[2]}
    num3=${BASH_REMATCH[3]}
    echo $[ $num1 * 10000 + $num2 * 100 + $num3 ]
}

version=$(phpVersion)
cd /tmp/extensions

# Use multicore compilation if php version greater than 5.4
if [ ${version} -ge 50600 ]; then
    export mc="-j$(nproc)";
fi

# Mcrypt was DEPRECATED in PHP 7.1.0, and REMOVED in PHP 7.2.0.
if [ ${version} -lt 70200 ]; then
    apt install -y libmcrypt-dev \
    && docker-php-ext-install $mc mcrypt
fi

if [ "${PHP_REDIS}" != "false" ]; then
    mkdir redis \
    && tar -xf redis-${PHP_REDIS}.tgz -C redis --strip-components=1 \
    && ( cd redis && phpize && ./configure && make $mc && make install ) \
    && docker-php-ext-enable redis
fi

# swoole require PHP version 5.5 or later.
if [ "${PHP_SWOOLE}" != "false" ]; then
    mkdir swoole \
    && tar -xf swoole-${PHP_SWOOLE}.tgz -C swoole --strip-components=1 \
    && ( cd swoole && phpize && ./configure && make $mc && make install ) \
    && docker-php-ext-enable swoole
fi