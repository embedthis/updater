#
#   binary.sh.tst -- Test the updater binary
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

../updater --device ${DEVICE} --file updater.bin --host ${ENDPOINT} --product ${PRODUCT} --token ${TOKEN} --version ${VERSION} --cmd ../apply.sh model=pro

if [ $? = 0 ] ; then
    echo "pass"
else
    echo "fail"
fi
