#!/usr/bin/env bash

DEBUG="0"

ROUTEROS_HOST="$1"
USERNAME="$2"
PASSWORD="$3"

LISTS_PATH="$4"

if [ -z "${LISTS_PATH}" ]
then
	echo "missing lists path" >&2
	exit 1
fi

if [ -d "${LISTS_PATH}" ]
then
#	find "${LISTS_PATH}" -type f -exec bash update-address-list-from-file.sh ${ROUTEROS_HOST} ${USERNAME} ${PASSWORD} {} {} \;
	find "${LISTS_PATH}" -type f | parallel bash update-address-list-from-file.sh ${ROUTEROS_HOST} ${USERNAME} ${PASSWORD} {} {}
else
	echo "missing lists directory" >&2
	exit 1
fi
