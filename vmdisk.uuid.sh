#!/bin/bash

set -x


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
CURLOPTS2="--insecure -s -H $CT"

JQ=/usr/local/bin/jq
JQOPTS="-r"
KEYVAL=".entities[].vm_disk_info[0].disk_address.vmdisk_uuid"

#response code
STATUS=$($CURL $CURLOPTS1 -X GET -u $USER:$PASSWORD "${BASE_URL}${VM}")
echo $STATUS

#parsed json values using jq v1.5
#VALUE=$($CURL $CURLOPTS2 -X GET -u $USER:$PASSWORD "${BASE_URL}${VM}" | $JQ $JQOPTS $KEYVAL) 
eval "$CURL $CURLOPTS2 -X GET -u $USER:$PASSWORD "${BASE_URL}${VM}" | $JQ $JQOPTS $KEYVAL" 
#echo $VALUE
  
