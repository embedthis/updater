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

node ../src/updater.js --device ${DEVICE} --file updater.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --cmd ../src/apply.sh model=pro

if [ $? = 0 ] ; then
    echo "✓ Update passed"
    rm -f updater.bin
else
    echo "✗ Update failed"
    rm -f updater.bin
    exit 1
fi
