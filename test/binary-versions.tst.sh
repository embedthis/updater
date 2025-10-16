#!/bin/bash
#
#   binary-versions.tst.sh -- Test version handling in updater binary
#
#   Tests version scenarios: multiple properties, old versions, and future versions.
#   Note: Old version test (0.0.1) may trigger actual update download and be slower.
#

FAILED=0

# Use process ID to create unique filenames for parallel test execution
PID=$$

# Test 1: Multiple properties
echo "Test 1: Multiple device properties"
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

# Test 2: Very old version (should likely get update)
echo "Test 2: Check with old version"
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

# Test 3: Very new version (should not get update)
echo "Test 3: Check with future version"
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
    echo "✓ All version handling tests passed"
    exit 0
else
    echo ""
    echo "✗ Some version handling tests failed"
    exit 1
fi
