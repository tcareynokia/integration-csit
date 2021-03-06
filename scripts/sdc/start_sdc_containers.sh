#!/bin/bash
#
# ============LICENSE_START=======================================================
# ONAP CLAMP
# ================================================================================
# Copyright (C) 2017 AT&T Intellectual Property. All rights
#                             reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END============================================
# ===================================================================
# ECOMP is a trademark and service mark of AT&T Intellectual Property.
#

echo "This is ${WORKSPACE}/scripts/sdc/start_sdc_containers.sh"

source ${WORKSPACE}/data/clone/sdc/version.properties
export RELEASE=$major.$minor-STAGING-latest
export DEP_ENV=$ENV_NAME
#[ -f /opt/config/nexus_username.txt ] && NEXUS_USERNAME=$(cat /opt/config/nexus_username.txt)    || NEXUS_USERNAME=release
#[ -f /opt/config/nexus_password.txt ] && NEXUS_PASSWD=$(cat /opt/config/nexus_password.txt)      || NEXUS_PASSWD=sfWU3DFVdBr7GVxB85mTYgAW
#[ -f /opt/config/nexus_docker_repo.txt ] && NEXUS_DOCKER_REPO=$(cat /opt/config/nexus_docker_repo.txt) || NEXUS_DOCKER_REPO=ecomp-nexus:${PORT}
#[ -f /opt/config/nexus_username.txt ] && docker login -u $NEXUS_USERNAME -p $NEXUS_PASSWD $NEXUS_DOCKER_REPO
export IP=$HOST_IP
#export PREFIX=${NEXUS_DOCKER_REPO}'/openecomp'
export PREFIX='nexus3.onap.org:10001/openecomp'


function monitor_docker {

echo monitor $1 Docker
sleep 5
TIME_OUT=800
INTERVAL=20
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do

MATCH=`docker logs --tail 30 $1 | grep "DOCKER STARTED"`
echo MATCH is -- $MATCH

if [ -n "$MATCH" ]
 then
    echo DOCKER start finished in $TIME seconds
    break
  fi

  echo Sleep: $INTERVAL seconds before testing if $1 DOCKER is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]
 then
   echo -e "\e[1;31mTIME OUT: DOCKER was NOT fully started in $TIME_OUT seconds... Could cause problems ...\e[0m"
fi


}

#start Elastic-Search
docker run --detach --name sdc-es --env ENVNAME="${DEP_ENV}" --log-driver=json-file --log-opt max-size=100m --log-opt max-file=10 --memory 1g --memory-swap=1g --ulimit memlock=-1:-1 --ulimit nofile=4096:100000 --volume /etc/localtime:/etc/localtime:ro -e ES_HEAP_SIZE=1024M --volume ${WORKSPACE}/data/ES:/usr/share/elasticsearch/data --volume ${WORKSPACE}/data/environments:/root/chef-solo/environments --publish 9200:9200 --publish 9300:9300 ${PREFIX}/sdc-elasticsearch:${RELEASE}

#start cassandra
docker run --detach --name sdc-cs --env RELEASE="${RELEASE}" --env ENVNAME="${DEP_ENV}" --env HOST_IP=${IP} --log-driver=json-file --log-opt max-size=100m --log-opt max-file=10 --ulimit memlock=-1:-1 --ulimit nofile=4096:100000 --volume /etc/localtime:/etc/localtime:ro --volume ${WORKSPACE}/data/CS:/var/lib/cassandra --volume ${WORKSPACE}/data/environments:/root/chef-solo/environments --publish 9042:9042 --publish 9160:9160 ${PREFIX}/sdc-cassandra:${RELEASE}

echo "please wait while CS is starting..."
monitor_docker sdc-cs


#start kibana
#docker run --detach --name sdc-kbn --env ENVNAME="${DEP_ENV}" --log-driver=json-file --log-opt max-size=100m --log-opt max-file=10 --ulimit memlock=-1:-1 --memory 2g --memory-swap=2g --ulimit nofile=4096:100000 --volume /etc/localtime:/etc/localtime:ro --volume ${WORKSPACE}/data/environments:/root/chef-solo/environments --publish 5601:5601 ${PREFIX}/sdc-kibana:${RELEASE}

#start sdc-backend
docker run --detach --name sdc-BE --env HOST_IP=${IP} --env ENVNAME="${DEP_ENV}" --env http_proxy=${http_proxy} --env https_proxy=${https_proxy} --env no_proxy=${no_proxy} --log-driver=json-file --log-opt max-size=100m --log-opt max-file=10 --ulimit memlock=-1:-1 --memory 4g --memory-swap=4g --ulimit nofile=4096:100000 --volume /etc/localtime:/etc/localtime:ro --volume ${WORKSPACE}/data/logs/BE/:/var/lib/jetty/logs  --volume ${WORKSPACE}/data/environments:/root/chef-solo/environments --publish 8443:8443 --publish 8080:8080 ${PREFIX}/sdc-backend:${RELEASE}

echo "please wait while BE is starting..."
monitor_docker sdc-BE

#start Front-End
docker run --detach --name sdc-FE --env HOST_IP=${IP} --env ENVNAME="${DEP_ENV}" --env http_proxy=${http_proxy} --env https_proxy=${https_proxy} --env no_proxy=${no_proxy} --log-driver=json-file --log-opt max-size=100m --log-opt max-file=10 --ulimit memlock=-1:-1 --memory 2g --memory-swap=2g --ulimit nofile=4096:100000 --volume /etc/localtime:/etc/localtime:ro  --volume ${WORKSPACE}/data/logs/FE/:/var/lib/jetty/logs --volume ${WORKSPACE}/data/environments:/root/chef-solo/environments --publish 9443:9443 --publish 8181:8181 ${PREFIX}/sdc-frontend:${RELEASE}

echo "docker run sdc-frontend..."
monitor_docker sdc-FE

echo " WAIT 1 minutes maximum and test every 5 seconds if SDC up using HealthCheck API...."

TIME_OUT=60
INTERVAL=5
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do
  response=$(curl --write-out '%{http_code}' --silent --output /dev/null http://localhost:8080/sdc2/rest/healthCheck); echo $response

  if [ "$response" == "200" ]; then
    echo SDC well started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if SDC is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: Docker containers not started in $TIME_OUT seconds... Could cause problems for tests...
fi

