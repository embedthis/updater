#
#   javascript.sh.tst -- Test the updater.js script
#   

. .creds.sh

node ../updater.js --device ${DEVICE} --file updater.bin --host ${ENDPOINT} --product ${PRODUCT} --token ${TOKEN} --version ${VERSION} --cmd ../apply.sh model=pro

if [ $? = 0 ] ; then
    echo "pass"
else
    echo "fail"
fi
