#
#   shell.sh.tst -- Test the updater.sh script
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

export VERSION DEVICE PRODUCT TOKEN ENDPOINT

bash ../updater.sh

if [ $? = 0 ] ; then
    echo "pass"
else
    echo "fail"
fi
