#!/bin/bash
#
#   javascript.sh.tst -- Test the updater.js script
#   

if [ -f .creds.sh ] ; then
    # Just for private testing (gitignored)
    . .creds.sh
elif [ ! -f creds.sh ] ; then
    echo 'Edit your cloud and product Builder credentials in the creds.sh'
    exit 2
else
    . creds.sh
fi

node ../updater.js --device ${DEVICE} --file updater.bin --host ${ENDPOINT} --product ${PRODUCT} --token ${TOKEN} --version ${VERSION} --cmd ../apply.sh model=pro

if [ $? = 0 ] ; then
    echo "pass"
else
    echo "fail"
fi
