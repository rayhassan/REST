#!/bin/bash

set -x
#    Copyright (C) <2014>  <ray@nutanix.com>
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# The following can be run in a shell in order to get the required data for json payload load below

# GET (1) : image name, storage container UUID and VM disk UUID (of image)
# /usr/bin/curl --insecure -s -H Content-Type:application/json -X GET \
# -u admin:nutanix/4u https://10.68.64.55:9440/PrismGateway/services/rest/v2.0/images/ | \
#  jq '.entities[] | "\(.name) \(.storage_container_uuid) \(.vm_disk_id)"|  \
# select(. and contains("CentOS7-TechSummit"))'

# Example output:
#"CentOS7-TechSummit c99819f0-bb38-4a5e-b473-48371ef8561c 2ec6918a-9cb1-487c-991d-5322dad5dee6"

# GET (2) : storage container UUID (where you will create VM) 
# /usr/bin/curl --insecure -s -H Content-Type:application/json -X GET \ 
# -u admin:nutanix/4u https://10.68.64.55:9440/PrismGateway/services/rest/v2.0/storage_containers/ \
# jq '.entities[] | "\(.name) \(.storage_container_uuid)"|  select(. and contains("DEFAULT-CTR"))'

# Example output
#"DEFAULT-CTR 2048afa6-a785-4aa8-b2b1-6124114ab91d"


# GET (3) : storage container UUID of (ISO/disk) image - needs to match UUID in GET(1)
# /usr/bin/curl --insecure -s -H Content-Type:application/json -X GET -u admin:nutanix/4u \
# https://10.68.64.55:9440/PrismGateway/services/rest/v2.0/storage_containers/ |i
#  jq '.entities[] | "\(.name) \(.storage_container_uuid)"|  select(. and contains("ImageStore"))'

# Example output
#"ImageStore c99819f0-bb38-4a5e-b473-48371ef8561c"

#### Main #####

#content type
CT="Content-Type:application/json"
USAGE="usage: $0 -u user -p password -i REST endpoint IP"

while getopts u:p:i: OPT
do
    case "$OPT" in
        u) USER="$OPTARG";;
        p) PASSWORD="$OPTARG";;
        i) IP="$OPTARG";;
        \?)     #unknown flag
            echo $USAGE >&2
            exit 1;;
         *)     #default
            echo $USAGE >&2
            exit 1;;
    esac
done
shift `expr $OPTIND - 1`

#services
PORT=${PORT:-9440}
BASE_URL="https://${IP}:${PORT}/PrismGateway/services/rest/v2.0"
RESPONSE_CODE="%{http_code}\n"

#resources
VM="/vms/"
SC="/storage_containers/"
IM="/images/"

CURL=/usr/bin/curl
CURLOPTS1="--write-out ${RESPONSE_CODE} --insecure -s --output /dev/null -H ${CT}"
#CURLOPTS2="--insecure -s -H $CT"

JQ=/usr/local/bin/jq
JQOPTS="-r"
KEYVAL=".entities[]"

#response code
STATUS=$($CURL $CURLOPTS1 -X POST -u $USER:$PASSWORD -d @json_payload "${BASE_URL}${VM}")
echo $STATUS

#parsed json values using jq v1.5
#VALUE=$($CURL $CURLOPTS2 -X GET -u $USER:$PASSWORD "${BASE_URL}${IM}" | $JQ $JQOPTS $KEYVAL) 
#eval "$CURL $CURLOPTS2 -X GET -u $USER:$PASSWORD "${BASE_URL}${IM}" | $JQ $JQOPTS $KEYVAL" 
#echo $VALUE
  
