    docker exec -it cron_php /bin/sh -c "[ -e /bin/bash ] && /bin/bash || /bin/sh"

    version: "3"
    services:

    cron_php:
        build:
        context: ./cron_php
        args:
            PHP_VERSION: ${PHP72_VERSION}
            PHP_SWOOLE: 4.3.3
            PHP_REDIS: 4.3.0
            PHP_XDEBUG: 'true'
        privileged: true
        image   : cron:php-${PHP72_VERSION}
        volumes :
        - ${SOURCE_DIR}:/var/www/html/:rw
        - ./cron_php/confs/php.ini:/usr/local/etc/php/php.ini
        - ./cron_php/other/cronfile:/var/spool/cron/crontabs/cronfile
        container_name: "cron_php"
        extra_hosts:
        - "nhzlc.club:172.10.0.2"
        networks:
        qvpcbr:
            ipv4_address: 172.10.0.12

    networks:
    qvpcbr:
        ipam:
        config:
            - subnet: 172.10.0.0/16