FROM mkenney/npm:node-8-debian
ENV SCRIPTS_PATH=/src/scripts
#install vim
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils && apt-get install apt-file -y && apt-file update && apt-get install vim -y
#install cron
RUN apt-get install -y cron
#copy scripts
ADD scripts/backup-couchdb.sh $SCRIPTS_PATH
#install @cloudant/couchbackup
RUN npm install -g @cloudant/couchbackup
