#!/usr/bin/env bash

DEBUG="0"

ROUTEROS_HOST="$1"
USERNAME="$2"
PASSWORD="$3"

LIST_PATH="$4"

LIST_NAME="$5"

if [ -z "${LIST_NAME}" ]
then
	echo "missing list name" >&2
	exit 1
fi

if [ -f "${LIST_PATH}" ]
then
# Dump current list
	CURRENT_LIST=$(curl -q -k -u ${USERNAME}:${PASSWORD} -X POST "https://${ROUTEROS_HOST}/rest/ip/firewall/address-list/print" \
		-H "content-type: application/json" \
		--data "{\".query\":[\"list=${LIST_NAME}\"]}" | jq ".[].address" -r | egrep -v "(^#|^$)" | sort | uniq )


	NEW_LIST=$( cat "${LIST_PATH}" | egrep -v "(^#|^$)" | sort | uniq)

	TMP_CURRENT_LIST_FILE=$( mktemp )

	TMP_NEW_LIST_FILE=$( mktemp )	
	
	TMP_CLEANUP_TRANSACTION_FILE=$( mktemp )
	TMP_UPDATE_TRANSACTION_FILE=$( mktemp )

	echo "${CURRENT_LIST}" > "${TMP_CURRENT_LIST_FILE}"
	echo "${NEW_LIST}" > "${TMP_NEW_LIST_FILE}"


	DIFF=$(diff -u "${TMP_CURRENT_LIST_FILE}" "${TMP_NEW_LIST_FILE}" )

if [ "${DEBUG}" -gt "0" ];then
	if [ -z "${DIFF}" ]
	then
		echo "DIFF is empty"
	else
	        echo "DIFF Size: $(echo "${DIFF}"|wc -l)"
	        echo "${DIFF}"
	fi
fi
	if [ ! -z "${DIFF}" ]
	then

	DELETE_OBJECTS=$(echo "${DIFF}" |egrep "^\-" |sed "s@^\-@@g")
	ADD_OBJECTS=$(echo "${DIFF}" |egrep "^\+" |sed "s@^\+@@g")

	echo "${DELETE_OBJECTS}" > "${TMP_CLEANUP_TRANSACTION_FILE}"
	echo "${ADD_OBJECTS}" > "${TMP_UPDATE_TRANSACTION_FILE}"

	bash del-cidr-from-address-list.sh "${ROUTEROS_HOST}" "${USERNAME}" "${PASSWORD}" "${LIST_NAME}" "${TMP_CLEANUP_TRANSACTION_FILE}"
	bash add-cidr-to-address-list.sh "${ROUTEROS_HOST}" "${USERNAME}" "${PASSWORD}" "${LIST_NAME}" "${TMP_UPDATE_TRANSACTION_FILE}"
	else
		echo "DIFF is 0, no changes required" >&2
	fi
	echo "Finished transaction"	 >&2
else
	echo "missing list file, file doesn't exit" >&2
	exit 1
fi
