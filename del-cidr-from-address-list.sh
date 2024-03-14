#!/usr/bin/env bash

DEBUG="0"

ROUTEROS_HOST="$1"
USERNAME="$2"
PASSWORD="$3"

LIST_NAME="$4"

LIST_FILENAME="$5"

if [ ! -f "${LIST_FILENAME}" ]
then
	echo "The list filename doesn't exist" >&2
	exit 1
fi



if [ ! -z "${LIST_NAME}" ]
then

	while IFS= read -r line
	do
                if [ -z "${line}" ]
                then
                        continue
                fi

	        if [ "${DEBUG}" -gt "0" ];then
			echo -n "DEBUG LEVEL 1: Working on CIDR: " >&2
	                echo "${line}" >&2
	        fi

		VALUE_ID=$(curl -q -k -u ${USERNAME}:${PASSWORD} -X POST "https://${ROUTEROS_HOST}/rest/ip/firewall/address-list/print" \
			-H "content-type: application/json" \
			--data "{\".query\": [\"list=${LIST_NAME}\",\"address=${line}\"]}" | jq  -r '.[].".id"')
#		echo "VALUE_ID is: ${VALUE_ID}"
	if [ -z "${VALUE_ID}" ]
	then
		echo "There is no such address in the address list"
		continue
	else
		DEL_RES=$(curl -q -k -u ${USERNAME}:${PASSWORD} -X DELETE "https://${ROUTEROS_HOST}/rest/ip/firewall/address-list/${VALUE_ID}")
		if [ -z "${DEL_RES}" ]
		then
			echo "The address: ${line} was removed from list: ${LIST_NAME} successfulyy"
		else
			echo "There was an error removing the address: ${line} from list: ${LIST_NAME}}"
			echo "${DEL_RES}"
		fi
	fi
	done < ${LIST_FILENAME}
fi

