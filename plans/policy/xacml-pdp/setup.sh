#!/bin/bash
# ============LICENSE_START=======================================================
#  Copyright (C) 2019 AT&T Intellectual Property. All rights reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

docker run -d --name policy-xacml-pdp -p 6969:6969 -it nexus3.onap.org:10001/onap/policy-xacml-pdp:2.0.0-SNAPSHOT-latest 
docker ps -a
sleep 5
POLICY_PDPX_IP=`get-instance-ip.sh policy-xacml-pdp`
echo PDP-X IP IS ${POLICY_PDPX_IP}
# Wait for initialization
for i in {1..10}; do
   curl -sS ${POLICY_PDPX_IP}:6969 && break
   echo sleep $i
   sleep $i
done

ROBOT_VARIABLES="-v POLICY_PDPX_IP:${POLICY_PDPX_IP}"
