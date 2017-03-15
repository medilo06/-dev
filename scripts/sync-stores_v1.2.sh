#!/bin/bash

VERSION="Version 1.2,"
HISTORY="20170315: Added syslog supported logging (logger)"
USAGE="$/bin/bash sync-stores_v1.2.sh \
check your /etc/rsyslog.conf and enable *.info level to logged your messages in specified log file.
 *.info                 /var/log/messages"

	   
	   
DATE=`date '+%D | %r'`;
LOG="/var/log/sync-stores.sh.`date +'%Y%m%d'`.log"

if [ ! -f .credentials.yml ]
    then
        echo "$DATE:  Please run this script from a directory containing a .credentials.yml file" >> $LOG;
        /usr/bin/logger -p local0.notice -t sync-stores.sh  "Please run this script from a directory containing a .credentials.yml file";
        exit
fi

if [ -z $(which pip) ];
    then
        pushd ~
        curl -O https://bootstrap.pypa.io/get-pip.py
        python get-pip.py --user
        echo "export PATH=~/.local/bin:$PATH" >> ~/.bash_profile
        source ~/.bash_profile
        popd
fi

if [ -z $(which shyaml) ];
    then
        pip install shyaml
fi

if [ -z $(which aws) ];
    then
        pip install aws-shell
fi

MYSQLUSER=$(cat .credentials.yml | shyaml get-value mysql.prod.user)
MYSQLPASS=$(cat .credentials.yml | shyaml get-value mysql.prod.password)
MYSQLHOST=$(cat .credentials.yml | shyaml get-value mysql.prod.host)
MYSQLDBNAME=$(cat .credentials.yml | shyaml get-value mysql.prod.db_name)

if [ $MYSQLHOST != "localhost" ];
    then
        echo "$DATE:  This script cannot be run on production servers." >> $LOG;
        /usr/bin/logger -p local0.notice -t sync-stores.sh "This script cannot be run on production servers.";
        exit
fi

echo "$DATE:  Downloading updated list of stores and offers" >> $LOG;
/usr/bin/logger -p local0.notice -t sync-stores.sh "Downloading updated list of stores and offers";

x=`aws s3 cp s3://piggydev/stores_offers.sql stores_offers.sql`
/usr/bin/logger -p local0.notice -t sync-stores.sh "$DATE: $x”;

echo "$DATE:  Updating database" >> $LOG;
/usr/bin/logger -p local0.notice -t sync-stores.sh "Updating database";

mysql -u $MYSQLUSER -p$MYSQLPASS -h $MYSQLHOST $MYSQLDBNAME < stores_offers.sql

rm stores_offers.sql

echo "$DATE:  Done"  >> $LOG;
/usr/bin/logger -p local0.notice -t sync-stores.sh "Done";
