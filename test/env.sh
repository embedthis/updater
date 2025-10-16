#!/bin/bash
#
#	env.sh - Set the test environment and echo to stdout.
#	This includes credentials for the updater 
#
if [ "${GITHUB_ACTIONS}" != "true" ] ; then
    if [ -f .creds.sh ] ; then
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
fi
export DEVICE ENDPOINT PRODUCT TOKEN VERSION

echo "DEVICE=${DEVICE}"
echo "ENDPOINT=${ENDPOINT}"
echo "PRODUCT=${PRODUCT}"
echo "TOKEN=${TOKEN}"
echo "VERSION=${VERSION}"
exit 0