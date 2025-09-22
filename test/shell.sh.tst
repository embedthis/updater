#
#   shell.sh.tst -- Test the updater.sh script
#   

. .creds.sh

export VERSION DEVICE PRODUCT TOKEN ENDPOINT

bash ../updater.sh

if [ $? = 0 ] ; then
    echo "pass"
else
    echo "fail"
fi
