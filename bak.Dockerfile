ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm

ARG PHP_XDEBUG
ARG PHP_SWOOLE
ARG PHP_REDIS

# 更改aliyun源
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak
COPY ./sources/debian.list /etc/apt/sources.list
RUN apt-get update

# 运行 debian.sh      安装 cron redis swoole mcrypt
COPY ./installs/debian.sh /tmp/extensions/
COPY ./other/redis-4.3.0.tgz /tmp/extensions/
COPY ./other/swoole-4.3.3.tgz /tmp/extensions/
RUN chmod +x /tmp/extensions/debian.sh \
    && /tmp/extensions/debian.sh \
    && rm -rf /tmp/extensions

RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install $mc gd \
    && :\
    && apt-get install -y libicu-dev \
    && docker-php-ext-install $mc intl \
    && :\
    && apt-get install -y libbz2-dev \
    && docker-php-ext-install $mc bz2 \
    && :\
    && docker-php-ext-install $mc zip \
    && docker-php-ext-install $mc pcntl \
    && docker-php-ext-install $mc pdo_mysql \
    && docker-php-ext-install $mc mysqli \
    && docker-php-ext-install $mc mbstring \
    && docker-php-ext-install $mc exif \
    && :\
    && apt-get install -y libmemcached-dev zlib1g-dev \
    && pecl install memcached \
    && docker-php-ext-enable memcached \
    && :\
    # && pecl install sqlsrv pdo_sqlsrv \
    # && docker-php-ext-enable $mc sqlsrv \
    # && docker-php-ext-enable $mc pdo_sqlsrv \
    && :\
    && apt-get install -y curl \
    && apt-get install -y libcurl4-openssl-dev \
    && docker-php-ext-install $mc curl

# 运行计划任务
RUN touch /var/log/cron.log
CMD cron && tail -f /var/log/cron.log

# 覆盖计划任务 为 自定义
COPY ./entrypoints/cron.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/cron.sh
RUN ln -s /usr/local/bin/cron.sh /cron.sh
ENTRYPOINT ["cron.sh"]
