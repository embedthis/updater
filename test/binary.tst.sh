#!/bin/bash
#
#   binary.sh.tst -- Test the updater.c version
#

. creds.sh

FAILED=0

# Use process ID to create unique filenames for parallel test execution
PID=$$

# Test 1: Basic update check (may or may not have update available)
echo "Test 1: Basic update check"
updater --device ${DEVICE} --file binary-$PID-update.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --cmd ./apply.sh
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Basic update check passed (exit code: $RC)"
    rm -f binary-$PID-update.bin
else
    echo "✗ Basic update check failed unexpectedly (exit code: $RC)"
    rm -f binary-$PID-update.bin
    FAILED=1
fi

# Test 2: Update check with properties
echo "Test 2: Update check with device properties"
updater --device ${DEVICE} --file binary-$PID-props.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} model=pro region=us-west
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Update with properties passed (exit code: $RC)"
    rm -f binary-$PID-props.bin
else
    echo "✗ Update with properties failed unexpectedly (exit code: $RC)"
    rm -f binary-$PID-props.bin
    FAILED=1
fi

# Test 3: Verbose mode
echo "Test 3: Verbose mode"
updater --device ${DEVICE} --file binary-$PID-verbose.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --verbose --quiet
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Verbose mode passed (exit code: $RC)"
    rm -f binary-$PID-verbose.bin
else
    echo "✗ Verbose mode failed unexpectedly (exit code: $RC)"
    rm -f binary-$PID-verbose.bin
    FAILED=1
fi

# Test 4: Custom file path
echo "Test 4: Custom file path"
CUSTOM_FILE="/tmp/binary-$PID-custom.bin"
updater --device ${DEVICE} --file ${CUSTOM_FILE} --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION}
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Custom file path passed (exit code: $RC)"
    rm -f ${CUSTOM_FILE}
else
    echo "✗ Custom file path failed unexpectedly (exit code: $RC)"
    rm -f ${CUSTOM_FILE}
    FAILED=1
fi

# Test 5: Missing required parameter (should fail)
echo "Test 5: Missing required parameter (--device)"
updater --file binary-$PID-error.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --quiet
RC=$?
if [ $RC != 0 ] ; then
    echo "✓ Missing parameter correctly rejected (exit code: $RC)"
else
    echo "✗ Missing parameter should have been rejected (exit code: $RC)"
    rm -f binary-$PID-error.bin
    FAILED=1
fi

# Test 6: Invalid token (should fail with auth error)
echo "Test 6: Invalid token"
updater --device ${DEVICE} --file binary-$PID-badtoken.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token "invalid-token-12345" --version ${VERSION} --quiet
RC=$?
if [ $RC != 0 ] ; then
    echo "✓ Invalid token correctly rejected (exit code: $RC)"
    rm -f binary-$PID-badtoken.bin
else
    echo "✗ Invalid token should have been rejected (exit code: $RC)"
    rm -f binary-$PID-badtoken.bin
    FAILED=1
fi

# Test 7: Multiple properties
echo "Test 7: Multiple device properties"
updater --device ${DEVICE} --file binary-$PID-multiprops.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} model=pro region=us-west tier=premium
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Multiple properties passed (exit code: $RC)"
    rm -f binary-$PID-multiprops.bin
else
    echo "✗ Multiple properties failed unexpectedly (exit code: $RC)"
    rm -f binary-$PID-multiprops.bin
    FAILED=1
fi

# Test 8: Very old version (should likely get update)
echo "Test 8: Check with old version"
updater --device ${DEVICE} --file binary-$PID-old.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version "0.0.1" --quiet
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Old version check passed (exit code: $RC)"
    rm -f binary-$PID-old.bin
else
    echo "✗ Old version check failed unexpectedly (exit code: $RC)"
    rm -f binary-$PID-old.bin
    FAILED=1
fi

# Test 9: Very new version (should not get update)
echo "Test 9: Check with future version"
updater --device ${DEVICE} --file binary-$PID-new.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version "999.999.999" --quiet
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Future version check passed (exit code: $RC)"
    rm -f binary-$PID-new.bin
else
    echo "✗ Future version check failed unexpectedly (exit code: $RC)"
    rm -f binary-$PID-new.bin
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
