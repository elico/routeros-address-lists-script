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

		ADD_RES=$(curl -q -k -u ${USERNAME}:${PASSWORD} -X PUT "https://${ROUTEROS_HOST}/rest/ip/firewall/address-list" \
			-H "content-type: application/json" \
			--data "{\"list\":\"${LIST_NAME}\", \"address\": \"${line}\"}")
		echo "${ADD_RES}"
	done < ${LIST_FILENAME}
fi

