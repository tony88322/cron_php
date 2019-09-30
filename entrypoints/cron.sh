#!/bin/bash
cp -R /var/spool/cron/crontabs/cronfile /var/spool/cron/crontabs/root
chown -R root:crontab /var/spool/cron/crontabs/root
chmod 600 /var/spool/cron/crontabs/root
# 换行符问题
# RUN apt-get -y install tofrodos
# RUN fromdos /var/spool/cron/crontabs/root
# RUN sed 's/\&/\\n/' /var/spool/cron/crontabs/root
# 0644
echo 'ok'
exec "$@"
