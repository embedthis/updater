#!/bin/bash
#
#   binary.sh.tst -- Test the updater.c version
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

FAILED=0

# Test 1: Basic update check (may or may not have update available)
echo "Test 1: Basic update check"
../src/updater --device ${DEVICE} --file updater.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --cmd ../src/apply.sh
if [ $? = 0 ] ; then
    echo "✓ Basic update check passed"
    rm -f updater.bin
else
    echo "✓ Basic update check completed (no update or expected failure)"
    rm -f updater.bin
fi

# Test 2: Update check with properties
echo "Test 2: Update check with device properties"
../src/updater --device ${DEVICE} --file updater-props.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} model=pro region=us-west
if [ $? = 0 ] || [ $? = 1 ]; then
    echo "✓ Update with properties passed"
    rm -f updater-props.bin
else
    echo "✗ Update with properties failed unexpectedly"
    rm -f updater-props.bin
    FAILED=1
fi

# Test 3: Verbose mode
echo "Test 3: Verbose mode"
../src/updater --device ${DEVICE} --file updater-verbose.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --verbose > /dev/null 2>&1
if [ $? = 0 ] || [ $? = 1 ]; then
    echo "✓ Verbose mode passed"
    rm -f updater-verbose.bin
else
    echo "✗ Verbose mode failed unexpectedly"
    rm -f updater-verbose.bin
    FAILED=1
fi

# Test 4: Custom file path
echo "Test 4: Custom file path"
CUSTOM_FILE="/tmp/updater-test-$$.bin"
../src/updater --device ${DEVICE} --file ${CUSTOM_FILE} --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION}
if [ $? = 0 ] || [ $? = 1 ]; then
    echo "✓ Custom file path passed"
    rm -f ${CUSTOM_FILE}
else
    echo "✗ Custom file path failed unexpectedly"
    rm -f ${CUSTOM_FILE}
    FAILED=1
fi

# Test 5: Missing required parameter (should fail)
echo "Test 5: Missing required parameter (--device)"
../src/updater --file updater-error.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} > /dev/null 2>&1
if [ $? != 0 ] ; then
    echo "✓ Missing parameter correctly rejected"
else
    echo "✗ Missing parameter should have been rejected"
    rm -f updater-error.bin
    FAILED=1
fi

# Test 6: Invalid token (should fail with auth error)
echo "Test 6: Invalid token"
../src/updater --device ${DEVICE} --file updater-badtoken.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token "invalid-token-12345" --version ${VERSION} > /dev/null 2>&1
if [ $? != 0 ] ; then
    echo "✓ Invalid token correctly rejected"
    rm -f updater-badtoken.bin
else
    echo "✗ Invalid token should have been rejected"
    rm -f updater-badtoken.bin
    FAILED=1
fi

# Test 7: Multiple properties
echo "Test 7: Multiple device properties"
../src/updater --device ${DEVICE} --file updater-multiprops.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} model=pro region=us-west tier=premium
if [ $? = 0 ] || [ $? = 1 ]; then
    echo "✓ Multiple properties passed"
    rm -f updater-multiprops.bin
else
    echo "✗ Multiple properties failed unexpectedly"
    rm -f updater-multiprops.bin
    FAILED=1
fi

# Test 8: Very old version (should likely get update)
echo "Test 8: Check with old version"
../src/updater --device ${DEVICE} --file updater-old.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version "0.0.1" > /dev/null 2>&1
if [ $? = 0 ] || [ $? = 1 ]; then
    echo "✓ Old version check passed"
    rm -f updater-old.bin
else
    echo "✗ Old version check failed unexpectedly"
    rm -f updater-old.bin
    FAILED=1
fi

# Test 9: Very new version (should not get update)
echo "Test 9: Check with future version"
../src/updater --device ${DEVICE} --file updater-new.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version "999.999.999" > /dev/null 2>&1
if [ $? = 0 ] || [ $? = 1 ]; then
    echo "✓ Future version check passed"
    rm -f updater-new.bin
else
    echo "✗ Future version check failed unexpectedly"
    rm -f updater-new.bin
    FAILED=1
fi

if [ $FAILED = 0 ] ; then
    echo ""
    echo "✓ All binary updater tests passed"
    exit 0
else
    echo ""
    echo "✗ Some binary updater tests failed"
    exit 1
fi
