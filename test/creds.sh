#!/bin/bash
#
#	creds.sh - Credentials for the updater
#
if [ "${GITHUB_ACTIONS}" = "true" ] ; then
    VERSION="1.0.0"
    DEVICE="UPDATER001"
elif [ -f .creds.sh ] ; then
    # Just for local testing
    . .creds.sh
else
    #
    # 	Set these to your product and device ID
    #
    VERSION="YOUR-VERSION-HERE"
    DEVICE="YOUR-DEVICE-ID-HERE"

    #
    # 	Get these values from your Builder Product and Cloud
    #
    PRODUCT="PRODUCT-ID-HERE"
    TOKEN="CLOUDAPI-TOKEN-HERE"
    ENDPOINT="CLOUD-ENDPOINT-HERE"
fi

#
#   If --print argument is provided, output credentials in parseable format
#   This is used by C tests to read credentials
#
if [ "$1" = "--print" ] ; then
    echo "ENDPOINT=${ENDPOINT}"
    echo "PRODUCT=${PRODUCT}"
    echo "TOKEN=${TOKEN}"
    echo "DEVICE=${DEVICE}"
    echo "VERSION=${VERSION}"
fi
