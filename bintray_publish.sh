#!/usr/bin/env bash

set -e -u

if [ "$#" = "0" ]; then
	echo "Usage: bintray_publish.sh [path to packages.json]"
	exit 1
else
	if [ -f "$1" ]; then
		PACKAGES_JSON_PATH="$1"
	else
		echo "Error: '$1' is not a file."
		exit 1
	fi
fi

if [ -z "$BINTRAY_USERNAME" ]; then
	echo "Environment variable 'BINTRAY_USERNAME' is not set !"
	exit 1
fi

if [ -z "$BINTRAY_API_KEY" ]; then
	echo "Environment variable 'BINTRAY_API_KEY' is not set !"
	exit 1
fi

BINTRAY_SUBJECT="termux"
BINTRAY_REPO_NAME="metadata"
BINTRAY_PACKAGE_NAME="repology"

# Check dependencies.
if [ -z "$(command -v curl)" ]; then
	echo "[!] Package 'curl' is not installed."
	exit 1
fi
if [ -z "$(command -v jq)" ]; then
	echo "[!] Package 'jq' is not installed."
	exit 1
fi

get_status_code() {
	echo "$1" | cut -d'|' -f2
}

get_api_response_message() {
	echo "$1" | cut -d'|' -f1 | jq -r .message
}

##
##  Deleting previous metadata objects.
##

echo -n "[*] Deleting previous metadata... "

curl_response=$(
	curl \
		--silent \
		--user "${BINTRAY_USERNAME}:${BINTRAY_API_KEY}" \
		--request DELETE \
		--write-out "|%{http_code}" \
		"https://api.bintray.com/content/${BINTRAY_SUBJECT}/${BINTRAY_REPO_NAME}/${BINTRAY_PACKAGE_NAME}/packages.json"
)

if [[ $(get_status_code "$curl_response") = "200" ]] || [[ $(get_status_code "$curl_response") = "404" ]]; then
	echo "success"
else
	get_api_response_message "$curl_response"
fi

##
##  Uploading new metadata.
##

echo -n "[*] Uploading new metadata... "

curl_response=$(
	curl \
		--silent \
		--user "${BINTRAY_USERNAME}:${BINTRAY_API_KEY}" \
		--request PUT \
		--header "X-Bintray-Package: ${BINTRAY_PACKAGE_NAME}" \
		--header "X-Bintray-Version: current" \
		--header "X-Bintray-Publish: 1" \
		--upload-file "$PACKAGES_JSON_PATH" \
		--write-out "|%{http_code}" \
        "https://api.bintray.com/content/${BINTRAY_SUBJECT}/${BINTRAY_REPO_NAME}/${BINTRAY_PACKAGE_NAME}/packages.json"
)

if [[ $(get_status_code "$curl_response") = "201" ]] || [[ $(get_status_code "$curl_response") = "409" ]]; then
	echo "success"
else
	get_api_response_message "$curl_response"
	exit 1
fi
