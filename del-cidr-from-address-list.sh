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

function join_by {
    local delimiter=${1-}
    local format=${2-}
    if shift 2; then
        printf "%s" "$format" "${@/#/$delimiter}"
    fi
}
IDS_TO_REMOVE=()

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
		echo "VALUE_ID is: ${VALUE_ID}"
	if [ -z "${VALUE_ID}" ]
	then
		echo "There is no such address in the address list"
		continue
	else
		IDS_TO_REMOVE+=( "${VALUE_ID}" )
	fi
	done < ${LIST_FILENAME}

	JOINED_IDS=$(join_by "," "${IDS_TO_REMOVE[@]}")


	DEL_RES=$(curl -q -k -u ${USERNAME}:${PASSWORD} -X POST --url "https://${ROUTEROS_HOST}/rest/ip/firewall/address-list/remove" \
		--header 'Content-Type: application/json' \
		--data "{\".id\": \"${JOINED_IDS}\"}")

	if [ "${DEL_RES}" == "[]" ]
	then
		echo "The address: ${JOINED_IDS} was removed from list: ${LIST_NAME} successfully"
	else
		echo "There was an error removing the address: ${line} from list: ${LIST_NAME}}"
		echo "${DEL_RES}"
	fi
fi
