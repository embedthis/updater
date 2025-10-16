#!/bin/bash
#
#   javascript.sh.tst -- Test the updater.js script
#

FAILED=0

# Use process ID to create unique filenames for parallel test execution
PID=$$

# Test 1: Basic update check (may or may not have update available)
echo "Test 1: Basic update check"
bun ../src/updater.js --device ${DEVICE} --file js-$PID-update.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --cmd ./apply.sh
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Basic update check passed (exit code: $RC)"
    rm -f js-$PID-update.bin
else
    echo "✗ Basic update check failed unexpectedly (exit code: $RC)"
    rm -f js-$PID-update.bin
    FAILED=1
fi

# Test 2: Update check with properties
echo "Test 2: Update check with device properties"
bun ../src/updater.js --device ${DEVICE} --file js-$PID-props.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} model=pro region=us-west
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Update with properties passed (exit code: $RC)"
    rm -f js-$PID-props.bin
else
    echo "✗ Update with properties failed unexpectedly (exit code: $RC)"
    rm -f js-$PID-props.bin
    FAILED=1
fi

# Test 3: Verbose mode
echo "Test 3: Verbose mode"
bun ../src/updater.js --device ${DEVICE} --file js-$PID-verbose.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --verbose --quiet
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Verbose mode passed (exit code: $RC)"
    rm -f js-$PID-verbose.bin
else
    echo "✗ Verbose mode failed unexpectedly (exit code: $RC)"
    rm -f js-$PID-verbose.bin
    FAILED=1
fi

# Test 4: Custom file path
echo "Test 4: Custom file path"
CUSTOM_FILE="js-$PID-custom.bin"
bun ../src/updater.js --device ${DEVICE} --file ${CUSTOM_FILE} --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION}
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Custom file path passed (exit code: $RC)"
    rm -f ${CUSTOM_FILE}
else
    echo "✗ Custom file path failed unexpectedly (exit code: $RC)"
    bun ../src/updater.js --device ${DEVICE} --file ${CUSTOM_FILE} --host ${ENDPOINT} \
        --product ${PRODUCT} --token ${TOKEN} --version ${VERSION}
    rm -f ${CUSTOM_FILE}
    FAILED=1
fi

# Test 5: Missing required parameter (should fail)
echo "Test 5: Missing required parameter (--device)"
bun ../src/updater.js --file js-$PID-error.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --quiet
RC=$?
if [ $RC != 0 ] ; then
    echo "✓ Missing parameter correctly rejected (exit code: $RC)"
else
    echo "✗ Missing parameter should have been rejected (exit code: $RC)"
    rm -f js-$PID-error.bin
    FAILED=1
fi

# Test 6: Invalid token (should fail with auth error)
echo "Test 6: Invalid token"
bun ../src/updater.js --device ${DEVICE} --file js-$PID-badtoken.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token "invalid-token-12345" --version ${VERSION} --quiet
RC=$?
if [ $RC != 0 ] ; then
    echo "✓ Invalid token correctly rejected (exit code: $RC)"
    rm -f js-$PID-badtoken.bin
else
    echo "✗ Invalid token should have been rejected (exit code: $RC)"
    rm -f js-$PID-badtoken.bin
    FAILED=1
fi

# Test 7: Multiple properties
echo "Test 7: Multiple device properties"
bun ../src/updater.js --device ${DEVICE} --file js-$PID-multiprops.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} model=pro region=us-west tier=premium
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Multiple properties passed (exit code: $RC)"
    rm -f js-$PID-multiprops.bin
else
    echo "✗ Multiple properties failed unexpectedly (exit code: $RC)"
    rm -f js-$PID-multiprops.bin
    FAILED=1
fi

# Test 8: Very old version (should likely get update)
echo "Test 8: Check with old version"
bun ../src/updater.js --device ${DEVICE} --file js-$PID-old.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version "0.0.1" --quiet
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Old version check passed (exit code: $RC)"
    rm -f js-$PID-old.bin
else
    echo "✗ Old version check failed unexpectedly (exit code: $RC)"
    rm -f js-$PID-old.bin
    FAILED=1
fi

# Test 9: Very new version (should not get update)
echo "Test 9: Check with future version"
bun ../src/updater.js --device ${DEVICE} --file js-$PID-new.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version "999.999.999" --quiet
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Future version check passed (exit code: $RC)"
    rm -f js-$PID-new.bin
else
    echo "✗ Future version check failed unexpectedly (exit code: $RC)"
    rm -f js-$PID-new.bin
    FAILED=1
fi

# Test 10: JSON response parsing (implicit in other tests)
echo "Test 10: Semantic version with pre-release"
bun ../src/updater.js --device ${DEVICE} --file js-$PID-semver.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version "1.0.0-beta.1" --quiet
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Semantic version test passed (exit code: $RC)"
    rm -f js-$PID-semver.bin
else
    echo "✗ Semantic version test failed unexpectedly (exit code: $RC)"
    rm -f js-$PID-semver.bin
    FAILED=1
fi

if [ $FAILED = 0 ] ; then
    echo ""
    echo "✓ All JavaScript updater tests passed"
    exit 0
else
    echo ""
    echo "✗ Some JavaScript updater tests failed"
    exit 1
fi
