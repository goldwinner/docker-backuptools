FROM mkenney/npm:node-8-debian
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils && apt-get install apt-file -y && apt-file update && apt-get install vim -y
RUN npm install -g @cloudant/couchbackup
