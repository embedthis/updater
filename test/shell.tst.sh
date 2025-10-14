#!/bin/bash
#
#   shell.sh.tst -- Test the updater.sh script
#

. creds.sh

FAILED=0
UPDATER_SH="../src/updater.sh"

# Use process ID to create unique filenames for parallel test execution
PID=$$

# Test 1: Basic update check
echo "Test 1: Basic update check with shell script"
bash "$UPDATER_SH" --device "${DEVICE}" --file shell-$PID-update.bin --host "${ENDPOINT}" \
    --product "${PRODUCT}" --token "${TOKEN}" --version "${VERSION}" --cmd ./apply.sh
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Shell script update check passed (exit code: $RC)"
    rm -f shell-$PID-update.bin
else
    echo "✗ Shell script update check failed unexpectedly (exit code: $RC)"
    rm -f shell-$PID-update.bin
    FAILED=1
fi

# Test 2: Old version (should trigger update)
echo "Test 2: Check with old version"
bash "$UPDATER_SH" --device "${DEVICE}" --file shell-$PID-old.bin --host "${ENDPOINT}" \
    --product "${PRODUCT}" --token "${TOKEN}" --version "0.0.1" --quiet
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Old version check passed (exit code: $RC)"
    rm -f shell-$PID-old.bin
else
    echo "✗ Old version check failed unexpectedly (exit code: $RC)"
    rm -f shell-$PID-old.bin
    FAILED=1
fi

# Test 3: Future version (should not get update)
echo "Test 3: Check with future version"
bash "$UPDATER_SH" --device "${DEVICE}" --file shell-$PID-future.bin --host "${ENDPOINT}" \
    --product "${PRODUCT}" --token "${TOKEN}" --version "999.999.999" --quiet
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Future version check passed (exit code: $RC)"
    rm -f shell-$PID-future.bin
else
    echo "✗ Future version check failed unexpectedly (exit code: $RC)"
    rm -f shell-$PID-future.bin
    FAILED=1
fi

# Test 4: Missing required parameter (should fail)
echo "Test 4: Missing required parameter (--device)"
bash "$UPDATER_SH" --file shell-$PID-error.bin --host "${ENDPOINT}" \
    --product "${PRODUCT}" --token "${TOKEN}" --version "${VERSION}" --quiet
RC=$?
if [ $RC != 0 ] ; then
    echo "✓ Missing parameter correctly rejected (exit code: $RC)"
else
    echo "✗ Missing parameter should have been rejected (exit code: $RC)"
    rm -f shell-$PID-error.bin
    FAILED=1
fi

# Test 5: Invalid token
echo "Test 5: Invalid token"
bash "$UPDATER_SH" --device "${DEVICE}" --file shell-$PID-badtoken.bin --host "${ENDPOINT}" \
    --product "${PRODUCT}" --token "invalid-token-12345" --version "${VERSION}" --quiet
RC=$?
if [ $RC != 0 ] ; then
    echo "✓ Invalid token correctly rejected (exit code: $RC)"
    rm -f shell-$PID-badtoken.bin
else
    echo "✗ Invalid token should have been rejected (exit code: $RC)"
    rm -f shell-$PID-badtoken.bin
    FAILED=1
fi

# Test 6: Update with device properties
echo "Test 6: Update with device properties"
bash "$UPDATER_SH" --device "${DEVICE}" --file shell-$PID-props.bin --host "${ENDPOINT}" \
    --product "${PRODUCT}" --token "${TOKEN}" --version "${VERSION}" model=pro region=us-west --quiet
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Update with properties passed (exit code: $RC)"
    rm -f shell-$PID-props.bin
else
    echo "✗ Update with properties failed unexpectedly (exit code: $RC)"
    rm -f shell-$PID-props.bin
    FAILED=1
fi

# Test 7: Verbose mode
echo "Test 7: Verbose mode"
bash "$UPDATER_SH" --device "${DEVICE}" --file shell-$PID-verbose.bin --host "${ENDPOINT}" \
    --product "${PRODUCT}" --token "${TOKEN}" --version "${VERSION}" --verbose --quiet
RC=$?
if [ $RC = 0 ] || [ $RC = 1 ]; then
    echo "✓ Verbose mode passed (exit code: $RC)"
    rm -f shell-$PID-verbose.bin
else
    echo "✗ Verbose mode failed unexpectedly (exit code: $RC)"
    rm -f shell-$PID-verbose.bin
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
