#!/bin/sh

PROGNAME=`basename $0`
VERSION="Version 0.1,"
AUTHOR="2015, John Ian Medilo"
HISTORY="20150612: modify for best"

CREDENTIALS="/srv/www/tmp/.credentials.yml" 

LOG_DIR="/srv/www/tmp"
LOG_FILE="sql.export-import.log"

date=`date +%Y%m%d_%H`;
LOGGINGDATE=`date '+%D | %r'`;
LOGDATE=`date '+%Y%m%d'`;

######################
# Script Entry Point #
######################

if [ ! -f $CREDENTIALS ]
	then
		echo "Please run this script from a directory containing a .credentials.yml file"
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


print_help() {
	echo "Usage: dbtablecopy.sh [options] COMMAND"
	echo ""
	echo ""
	echo "$PROGNAME -s [SOURCE DB] -d [DESTINATION DB] -t [TABLE] --schema --data -y"
	echo "$PROGNAME -s testing -d testing -t test_table --schema --data -y"
	echo ""
	echo "Options:"
	echo "  -s/--sourceDB)"
	echo "     You need to provide a string for database source {prod|prod-rr|logs|logs-rr|development|testing}"
	echo "      "
	echo "  -d/--destinationDB)"
	echo "     You need to provide a string for database destination {prod|prod-rr|logs|logs-rr|development|testing}"
	echo "      "
	echo "  -t/--table)"
	echo "     You need to provide a string for table {affected table}"
	echo "      "	
	echo "  --schemadata)"
	echo "     Extract/Import database schema and data only."
	echo "      "	
	echo "  -y/--assumeyes)"
	echo "     Answer yes for all questions"
	echo "      "	
	exit 
	
}	
	
get_sourceDB() {
	SOURCEDATABASE=$1;
	SMYSQLUSER=$(cat $CREDENTIALS | shyaml get-value mysql.$SOURCEDATABASE.user)
	SMYSQLPASS=$(cat $CREDENTIALS | shyaml get-value mysql.$SOURCEDATABASE.password)
	SMYSQLHOST=$(cat $CREDENTIALS | shyaml get-value mysql.$SOURCEDATABASE.host)
	SMYSQLDBNAME=$(cat $CREDENTIALS | shyaml get-value mysql.$SOURCEDATABASE.db_name)
	dbsource_status="1";
	echo "$LOGGINGDATE: Establishing DB source credentials..." >> $LOG_DIR/$LOGDATE.$LOG_FILE
}

get_destinationDB() {
	DESTINATIONDATABASE=$1;
	DMYSQLUSER=$(cat $CREDENTIALS | shyaml get-value mysql.$DESTINATIONDATABASE.user)
	DMYSQLPASS=$(cat $CREDENTIALS | shyaml get-value mysql.$DESTINATIONDATABASE.password)
	DMYSQLHOST=$(cat $CREDENTIALS | shyaml get-value mysql.$DESTINATIONDATABASE.host)
	DMYSQLDBNAME=$(cat $CREDENTIALS | shyaml get-value mysql.$DESTINATIONDATABASE.db_name)
	dbdestination_status="1";
	echo "$LOGGINGDATE: Establishing DB destination credentials..." >> $LOG_DIR/$LOGDATE.$LOG_FILE
}
function get_schemadata() {
	echo "$LOGGINGDATE: Running mysql mdump (schema|data) for $SMYSQLHOST.$SMYSQLDBNAME.$AFFECTEDTABLE..." >> $LOG_DIR/$LOGDATE.$LOG_FILE
	mysqldump -u $SMYSQLUSER -p$SMYSQLPASS -h$SMYSQLHOST $SMYSQLDBNAME $AFFECTEDTABLE > $LOG_DIR/data.$date.$SMYSQLDBNAME.$AFFECTEDTABLE.sql
	echo "$LOGGINGDATE: Writing a copy of $SMYSQLHOST.$SOURCEDATABASE.$AFFECTEDTABLE to $DMYSQLHOST.$DESTINATIONDATABASE.$AFFECTEDTABLE..." >> $LOG_DIR/$LOGDATE.$LOG_FILE
	mysql -u$DMYSQLUSER -p$DMYSQLPASS -h$DMYSQLHOST $DMYSQLDBNAME < $LOG_DIR/data.$date.$SMYSQLDBNAME.$AFFECTEDTABLE.sql
	}
	

function get_tables() {
	AFFECTEDTABLE=$1;
	echo "$LOGGINGDATE: Indentifying affected table..." >> $LOG_DIR/$LOGDATE.$LOG_FILE
	dbtable_status="1";
}
	



while test -n "$1"; do
	case "$1" in
	--help|-h)
		print_help;
		exit 
		;;
	--sourceDB|-s)
		get_sourceDB $2
		shift
		;;
	--destinationDB|-d)
		get_destinationDB $2
		shift
		;;
	--table|-t)
		get_tables $2
		shift
		;;
	--schemadata)
		get_schemadata
		shift
		;;

	*)
		echo "Unknown argument: $1"
		print_help
		exit 
		;;
	esac
shift
done

