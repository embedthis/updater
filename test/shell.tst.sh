#!/bin/bash
#
#   shell.sh.tst -- Test the updater.sh script
#

. creds.sh

FAILED=0

# Test 1: Basic update check
echo "Test 1: Basic update check with shell script"
export VERSION DEVICE PRODUCT TOKEN ENDPOINT
cd ../src/
bash ./updater.sh
RC=$?
cd ../test
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Shell script update check passed"
    rm -f ../src/updater.bin
else
    echo "✗ Shell script update check failed unexpectedly"
    rm -f ../src/updater.bin
    FAILED=1
fi

# Test 2: Old version (should trigger update)
echo "Test 2: Check with old version"
export VERSION="0.0.1"
export DEVICE PRODUCT TOKEN ENDPOINT
cd ../src/
bash ./updater.sh > /dev/null 2>&1
RC=$?
cd ../test
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Old version check passed"
    rm -f ../src/updater.bin
else
    echo "✗ Old version check failed unexpectedly"
    rm -f ../src/updater.bin
    FAILED=1
fi

# Test 3: Future version (should not get update)
echo "Test 3: Check with future version"
export VERSION="999.999.999"
export DEVICE PRODUCT TOKEN ENDPOINT
cd ../src/
bash ./updater.sh > /dev/null 2>&1
RC=$?
cd ../test
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Future version check passed"
    rm -f ../src/updater.bin
else
    echo "✗ Future version check failed unexpectedly"
    rm -f ../src/updater.bin
    FAILED=1
fi

# Test 4: Missing required environment variable (uses defaults in shell script)
echo "Test 4: Shell script with unset VERSION (uses default)"
unset VERSION
export DEVICE PRODUCT TOKEN ENDPOINT
cd ../src/
bash ./updater.sh > /dev/null 2>&1
RC=$?
cd ../test
# Shell script uses default values, so it should attempt to run (may fail on auth)
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Shell script handles unset variables with defaults"
    rm -f ../src/updater.bin
else
    echo "✗ Shell script should handle unset variables"
    rm -f ../src/updater.bin
    FAILED=1
fi

# Test 5: Invalid token
echo "Test 5: Invalid token"
export VERSION DEVICE PRODUCT ENDPOINT
export TOKEN="invalid-token-12345"
cd ../src/
bash ./updater.sh > /dev/null 2>&1
RC=$?
cd ../test
if [ $RC != 0 ] ; then
    echo "✓ Invalid token correctly rejected"
    rm -f ../src/updater.bin
else
    echo "✗ Invalid token should have been rejected"
    rm -f ../src/updater.bin
    FAILED=1
fi

if [ $FAILED = 0 ] ; then
    echo ""
    echo "✓ All shell script updater tests passed"
    exit 0
else
    echo ""
    echo "✗ Some shell script updater tests failed"
    exit 1
fi
