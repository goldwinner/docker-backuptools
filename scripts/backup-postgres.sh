#!/bin/bash

###Backup Postgres######################
export PG_HOST=$1
export PG_USER=$2
export PG_PASS=$3
export PG_PORT=5432
export PG_PASSFILE=${HOME}/.pgpass
export PG_BAK_PATH=/app/databackup/postgres/
export PG_BAK_NAME=${PG_HOST}-$(date "+%Y%m%d-%H%M%S")

###Conditional judgment###
if [ ! -d ${PG_BAK_PATH} ];then
  echo "error!${PG_BAK_PATH} was not exist!"
  exit 234
fi
if [ ! -z "${PG_HOST}" ];then
  /bin/ping -c3 -i0.2 -W1 ${PG_HOST} >/dev/null 2>&1
    if [ $? -ne 0 ];then
      echo "error!${PG_HOST} is unreachable!please check again."
      exit 235
    fi
else 
  echo "USAGE:$0 host user"
  exit 236
fi
if [ -z "${PG_USER}" ];then
  echo "error!user can not be empty! USAGE:$0 host user"
  exit 237
fi
#create default password file if it is not exist
if [ ! -f ${PG_PASSFILE} ];then
  echo "${PG_HOST}:${PG_PORT}:*:${PG_USER}:${PG_PASS}" > ${PG_PASSFILE} 
  chmod 0600 ${PG_PASSFILE}
else
  PG_OLD_PASS=`awk -F [:] '{print $5}' ${PG_PASSFILE}`
  if [ "${PG_OLD_PASS}" != "${PG_PASS}" ];then
    echo "${PG_HOST}:${PG_PORT}:*:${PG_USER}:${PG_PASS}" > ${PG_PASSFILE}
    chmod 0600 ${PG_PASSFILE} 
  fi
fi
###starting backup postgres###
cd ${PG_BAK_PATH}
/usr/bin/pg_dumpall -h ${PG_HOST} -U ${PG_USER} -w |gzip >${PG_BAK_NAME}.dmp.gz
