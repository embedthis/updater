#
#   binary.sh.tst -- Test the updater binary
#   

. .creds.sh

echo "info Running updater"

../updater --device ${DEVICE} --file updater.bin --host ${ENDPOINT} --product ${PRODUCT} --token ${TOKEN} --version ${VERSION} --cmd ../apply.sh model=pro

if [ $? = 0 ] ; then
    echo "pass"
else
    echo "fail"
fi
