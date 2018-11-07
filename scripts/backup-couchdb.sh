#!/bin/bash

###Define Variables#######################
export COUCHDB_HOST=$1
export COUCHDB_USER=$2
export COUCHDB_PASS=$3
export COUCHDB_PORT=5984
export COUCH_URL=http://${COUCHDB_USER}:${COUCHDB_PASS}@${COUCHDB_HOST}:${COUCHDB_PORT}
export COUCHDB_BAK_PATH=/src/databackup/couchdb/
export COUCHDB_BAK_NAME=${COUCHDB_HOST}-$(date +%F)

###Conditional judgment###
if [ ! -d ${COUCHDB_BAK_PATH} ];then
  echo "error!${COUCHDB_BAK_PATH} was not exist!"
  exit 1
fi
if [ ! -z "${COUCHDB_HOST}" ];then
/bin/ping -c3 -i0.2 -W1 ${COUCHDB_HOST} >/dev/null 2>&1
    if [ $? -ne 0 ];then
      echo "error!${COUCHDB_HOST} is unreachable!please check again."
      exit 2
    fi
else 
  echo "USAGE:$0 host user pass"
  exit 236
fi
if [ -z "${COUCHDB_USER}" ];then
  echo "error!user can not be empty!  USAGE:$0 host user pass"
  exit 237
elif [ -z "${COUCHDB_PASS}" ];then
  echo "error!password can not be empty!  USAGE:$0 host user pass"
  exit 238
fi

###Starting backup couchdb###
cd ${COUCHDB_BAK_PATH}
for DB in `curl -Ls ${COUCH_URL}/_all_dbs|sed -e 's/\[//g' -e 's/\]//g' -e 's/\"//g'|tr -s "," " "`
do
  couchbackup --db ${DB} --log ${DB}.log | gzip > ${COUCHDB_HOST}-${DB}.json.gz
done
tar cf ${COUCHDB_BAK_NAME}.tar *.json.gz --remove-files
####Delete more than 30 days backup files###
cd ${COUCHDB_BAK_PATH}
find . -type f -name "*.tar" -mtime +30 | xargs rm -f
find . -type f -name "*.log" -mtime +30 | xargs rm -f
