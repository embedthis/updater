#!/bin/bash
#
#   binary-basic.tst.sh -- Test core functionality of updater binary
#
#   Tests basic operations: update checks, properties, verbose mode, and file paths.
#

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
    --token ${TOKEN} --version ${VERSION} --quiet
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Custom file path passed (exit code: $RC)"
    rm -f ${CUSTOM_FILE}
else
    echo "✗ Custom file path failed unexpectedly (exit code: $RC)"
    rm -f ${CUSTOM_FILE}
    FAILED=1
fi

if [ $FAILED = 0 ] ; then
    echo ""
    echo "✓ All basic functionality tests passed"
    exit 0
else
    echo ""
    echo "✗ Some basic functionality tests failed"
    exit 1
fi
