#!/usr/bin/env bash

if [ "${TESTME_OS}" = "windows" ] ; then
    ../bin/test-prep.bat
else
    ../bin/test-prep.sh
fi
exit 0
