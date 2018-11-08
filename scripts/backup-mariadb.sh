#!/bin/bash

###Define Variables#######################
export MYSQL_BAK_PATH=/app/databackup/mariadb
export MYSQL_IP=$1
export MYSQL_USER=$2
export MYSQL_PASS=$3
export MYSQL_BAK_NAME=${MYSQL_IP}-$(date "+%Y%m%d-%H%M%S").sql.gz
export MYSQL_FULL_NAME=all

###Conditional judgment###
if [ ! -d ${MYSQL_PATH} ];then
  echo "error!${MYSQL_PATH} was not exist!"
  exit 1
fi
if [ ! -d ${MYSQL_BAK_PATH} ];then
  echo "error!${MYSQL_BAK_PATH} was not exist!"
  exit 2
fi
if [ -z "${MYSQL_IP}" ];then
  echo "USAGE:$0 container_name"
  exit 3
fi
if [ ! -z "${MYSQL_IP}" ];then
  /bin/ping -c3 -i0.2 -W1 ${MYSQL_IP} >/dev/null 2>&1
    if [ $? -ne 0 ];then
      echo "error!${MYSQL_IP} is unreachable!please check again."
      exit 4
    fi
else 
  echo "USAGE:$0 host user pass"
  exit 5
fi
if [ -z "${MYSQL_USER}" ];then
  echo "error!user can not be empty!  USAGE:$0 host user pass"
  exit 6
fi
if [ -z "${MYSQL_PASS}" ];then
  echo "error!password can not be empty!  USAGE:$0 host user pass"
  exit 7
fi

###Starting backup mysql###
#single backup
for DB_LIST in `mysql -h${MYSQL_IP} -u${MYSQL_USER} -p${MYSQL_PASS} -e 'show databases;' | sed 1d | grep -v '_schema'`
do
  if [ ! -d ${MYSQL_BAK_PATH}/${DB_LIST} ];then
    mkdir -p ${MYSQL_BAK_PATH}/${DB_LIST}
  fi
mysqldump -h${MYSQL_IP} -u${MYSQL_USER} -p${MYSQL_PASS} ${DB_LIST} --single-transaction --routines --triggers --events| gzip > ${MYSQL_BAK_PATH}/${DB_LIST}/${DB_LIST}-${MYSQL_BAK_NAME}
done
#full backup
if [ ! -d ${MYSQL_BAK_PATH}/${MYSQL_FULL_NAME} ];then
  mkdir -p ${MYSQL_BAK_PATH}/${MYSQL_FULL_NAME}
fi
mysqldump -h${MYSQL_IP} -u${MYSQL_USER} -p${MYSQL_PASS}  --all-databases --single-transaction --routines --triggers --events| gzip > ${MYSQL_BAK_PATH}/${MYSQL_FULL_NAME}/${MYSQL_FULL_NAME}-${MYSQL_BAK_NAME}
####Delete more than 30 days backup files###
cd ${MYSQL_BAK_PATH}/
find . -type f -name "*.sql.gz" -mtime +30 | xargs rm -f
