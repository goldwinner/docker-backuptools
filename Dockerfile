FROM node:8.12-jessie
#install vim cron cloudant/couchbackup
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils && apt-get install apt-file -y && apt-file update && apt-get install vim -y && apt-get install cron -y && npm install -g @cloudant/couchbackup
COPY . /src
