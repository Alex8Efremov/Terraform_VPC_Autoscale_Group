#!/bin/bash
apt-get -y update
apt-get -y install apache2
apt-get -y install php libapache2-mod-php php-mysql php-mbstring
apt-get -y install git
# install awscli to get parameters from ParameterStore
apt-get -y install awscli

echo `ls /var/www/html/` >> /home/`whoami`/text.txt
# delete all files from html
rm /var/www/html/*
# assign apache user
cat <<EOF >/etc/apache2/envvars
# this won't be correct after changing uid
unset HOME

# for supporting multiple apache2 instances
if [ "${APACHE_CONFDIR##/etc/apache2-}" != "${APACHE_CONFDIR}" ] ; then
 SUFFIX="-${APACHE_CONFDIR##/etc/apache2-}"
else
 SUFFIX=
fi

# Since there is no sane way to get the parsed apache2 config in scripts, some
# settings are defined via environment variables and then used in apache2ctl,
# /etc/init.d/apache2, /etc/logrotate.d/apache2, etc.
export APACHE_RUN_USER=`whoami`
export APACHE_RUN_GROUP=www-data
# temporary state file location. This might be changed to /run in Wheezy+1
export APACHE_PID_FILE=/var/run/apache2$SUFFIX/apache2.pid
export APACHE_RUN_DIR=/var/run/apache2$SUFFIX
export APACHE_LOCK_DIR=/var/lock/apache2$SUFFIX
# Only /var/log/apache2 is handled by /etc/logrotate.d/apache2.
export APACHE_LOG_DIR=/var/log/apache2$SUFFIX

## The locale used by some modules like mod_dav
export LANG=C
## Uncomment the following line to use the system default locale instead:
#. /etc/default/locale

export LANG
EOF
# clone website from GitHub
git clone https://github.com/Alex8Efremov/GitHub_Actions.git /var/www/html/

sudo service apache2 start
