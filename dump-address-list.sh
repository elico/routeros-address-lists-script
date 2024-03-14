#!/usr/bin/env bash

ROUTEROS_HOST="$1"
USERNAME="$2"
PASSWORD="$3"

LIST_NAME="$4"

if [ ! -z "${LIST_NAME}" ]
then
	curl -q -k -u ${USERNAME}:${PASSWORD} -X POST "https://${ROUTEROS_HOST}/rest/ip/firewall/address-list/print" \
		-H "content-type: application/json" \
		--data "{\".query\":[\"list=${LIST_NAME}\"]}" | jq ".[].address" -r
else
	echo "missing list name" >&2
	exit 1
fi

