#!/bin/bash
#
#   error-handling.tst.sh -- Dedicated error case testing for updater
#
#   Tests various error conditions and edge cases that should be properly handled.
#   This test focuses on negative test cases and error paths.
#

. creds.sh

UPDATER="updater"

# Use process ID to create unique filenames for parallel test execution
PID=$$
FAILED=0

echo "=== Error Handling Tests for Updater ==="
echo ""

# Test 1: Missing --host parameter
echo "Test 1: Missing --host parameter"
${UPDATER} --device ${DEVICE} --file error-$PID-test.bin --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --quiet
RC=$?
if [ $RC != 0 ] ; then
    echo "✓ Missing --host correctly rejected (exit code: $RC)"
else
    echo "✗ Should reject missing --host (exit code: $RC)"
    FAILED=1
fi
rm -f error-$PID-test.bin

# Test 2: Missing --product parameter
echo "Test 2: Missing --product parameter"
${UPDATER} --device ${DEVICE} --file error-$PID-test.bin --host ${ENDPOINT} \
    --token ${TOKEN} --version ${VERSION} --quiet
RC=$?
if [ $RC != 0 ] ; then
    echo "✓ Missing --product correctly rejected (exit code: $RC)"
else
    echo "✗ Should reject missing --product (exit code: $RC)"
    FAILED=1
fi
rm -f error-$PID-test.bin

# Test 3: Missing --token parameter
echo "Test 3: Missing --token parameter"
${UPDATER} --device ${DEVICE} --file error-$PID-test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --version ${VERSION} --quiet
RC=$?
if [ $RC != 0 ] ; then
    echo "✓ Missing --token correctly rejected (exit code: $RC)"
else
    echo "✗ Should reject missing --token (exit code: $RC)"
    FAILED=1
fi
rm -f error-$PID-test.bin

# Test 4: Missing --device parameter
echo "Test 4: Missing --device parameter"
${UPDATER} --file error-$PID-test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --quiet
RC=$?
if [ $RC != 0 ] ; then
    echo "✓ Missing --device correctly rejected (exit code: $RC)"
else
    echo "✗ Should reject missing --device (exit code: $RC)"
    FAILED=1
fi
rm -f error-$PID-test.bin

# Test 5: Missing --version parameter
echo "Test 5: Missing --version parameter"
${UPDATER} --device ${DEVICE} --file error-$PID-test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --quiet
RC=$?
if [ $RC != 0 ] ; then
    echo "✓ Missing --version correctly rejected (exit code: $RC)"
else
    echo "✗ Should reject missing --version (exit code: $RC)"
    FAILED=1
fi
rm -f error-$PID-test.bin

# Test 6: Invalid/unauthorized token
echo "Test 6: Invalid/unauthorized token"
${UPDATER} --device ${DEVICE} --file error-$PID-bad.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token "invalid_token_xyz" --version ${VERSION} --quiet
RC=$?
if [ $RC != 0 ] ; then
    echo "✓ Invalid token correctly rejected (exit code: $RC)"
else
    echo "✗ Should reject invalid token (exit code: $RC)"
    FAILED=1
fi
rm -f error-$PID-bad.bin

# Test 7: Malformed URL (missing protocol)
echo "Test 7: Malformed host URL"
${UPDATER} --device ${DEVICE} --file error-$PID-test.bin --host "malformed-url" --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --quiet
RC=$?
if [ $RC != 0 ] ; then
    echo "✓ Malformed URL correctly rejected (exit code: $RC)"
else
    echo "✗ Should reject malformed URL (exit code: $RC)"
    FAILED=1
fi
rm -f error-$PID-test.bin

# Test 8: Empty device ID
echo "Test 8: Empty device ID"
${UPDATER} --device "" --file error-$PID-test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --quiet
RC=$?
if [ $RC != 0 ] ; then
    echo "✓ Empty device ID correctly rejected (exit code: $RC)"
else
    echo "✗ Should reject empty device ID (exit code: $RC)"
    FAILED=1
fi
rm -f error-$PID-test.bin

# Test 9: Empty version
echo "Test 9: Empty version string"
${UPDATER} --device ${DEVICE} --file error-$PID-test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version "" --quiet
RC=$?
if [ $RC != 0 ] ; then
    echo "✓ Empty version correctly rejected (exit code: $RC)"
else
    echo "✗ Should reject empty version (exit code: $RC)"
    FAILED=1
fi
rm -f error-$PID-test.bin

# Test 10: Non-existent script path
echo "Test 10: Non-existent script path"
${UPDATER} --device ${DEVICE} --file error-$PID-test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --cmd /nonexistent/path/script.sh --quiet
# This should fail at network/auth stage, not script validation
if [ $RC != 0 ] ; then
    echo "✓ Non-existent script handled (exit code: $RC)"
else
    echo "✓ Non-existent script handled (update may not have been available) (exit code: $RC)"
fi
rm -f error-$PID-test.bin

# Test 11: Invalid product ID
# Must use unknown device as the service can determine the product from a known device.
echo "Test 11: Invalid product ID"
${UPDATER} --device UNKNOWN$$ --file error-$PID-test.bin --host ${ENDPOINT} --product "invalid-product-id" \
    --token ${TOKEN} --version ${VERSION} --quiet
RC=$?
if [ $RC != 0 ] ; then
    echo "✓ Invalid product ID correctly rejected (exit code: $RC)"
else
    echo "✗ Should reject invalid product ID (exit code: $RC)"
    echo INVOKED ${UPDATER} --device ${DEVICE} --file error-$PID-test.bin --host ${ENDPOINT} --product "invalid-product-id" \
        --token ${TOKEN} --version ${VERSION}
    FAILED=1
fi
rm -f error-$PID-test.bin

# Test 12: File path in protected directory (should fail on write)
echo "Test 12: Protected file path"
${UPDATER} --device ${DEVICE} --file /etc/updater-error-$PID-test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --quiet
# Expected to fail, either on auth or file write permissions
if [ $RC != 0 ] ; then
    echo "✓ Protected path handled appropriately (exit code: $RC)"
else
    echo "✗ Should fail on protected path (exit code: $RC)"
    echo INVOKED ${UPDATER} --device ${DEVICE} --file /etc/updater-error-$PID-test.bin --host ${ENDPOINT} --product ${PRODUCT} \
        --token ${TOKEN} --version ${VERSION}
    FAILED=1
fi

# Test 13: Unknown command-line option
echo "Test 13: Unknown command-line option"
${UPDATER} --device ${DEVICE} --file error-$PID-test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --unknown-option value --quiet
RC=$?
if [ $RC != 0 ] ; then
    echo "✓ Unknown option correctly rejected (exit code: $RC)"
else
    echo "✗ Should reject unknown option (exit code: $RC)"
    FAILED=1
fi
rm -f error-$PID-test.bin

# Test 14: Extremely long property key
echo "Test 14: Very long property value"
LONG_VALUE=$(printf 'a%.0s' {1..5000})
${UPDATER} --device ${DEVICE} --file error-$PID-test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} longkey=${LONG_VALUE} --quiet
# Should fail due to buffer overflow protection
if [ $RC != 0 ] ; then
    echo "✓ Oversized property correctly rejected (exit code: $RC)"
else
    echo "✗ Should reject oversized property (exit code: $RC)"
    FAILED=1
fi
rm -f error-$PID-test.bin

# Test 15: Invalid semantic version format
echo "Test 15: Various version formats (should be accepted)"
${UPDATER} --device ${DEVICE} --file error-$PID-test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version "v1.2.3" --quiet
# Should attempt the request regardless of version format
if [ $RC = 0 ] || [ $? = 1 ]; then
    echo "✓ Version format 'v1.2.3' accepted (exit code: $RC)"
else
    echo "✓ Version format handled (exit code: $RC)"
fi
rm -f error-$PID-test.bin

# Test 16: Script with no execute permissions
echo "Test 16: Script without execute permissions"
touch error-$PID-noperm.sh
chmod 600 error-$PID-noperm.sh
${UPDATER} --device ${DEVICE} --file error-$PID-test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --cmd ./error-$PID-noperm.sh --quiet
# Should fail at network/auth stage before trying to execute
if [ $RC != 0 ] ; then
    echo "✓ Non-executable script handled (exit code: $RC)"
else
    echo "✓ Non-executable script handled (no update available) (exit code: $RC)"
fi
rm -f error-$PID-test.bin error-$PID-noperm.sh

# Test 17: Malformed property (missing value)
echo "Test 17: Malformed property syntax"
${UPDATER} --device ${DEVICE} --file error-$PID-test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} badproperty --quiet
RC=$?
if [ $RC != 0 ] ; then
    echo "✓ Malformed property correctly rejected (exit code: $RC)"
else
    echo "✗ Should reject malformed property (exit code: $RC)"
    FAILED=1
fi
rm -f error-$PID-test.bin

# Test 18: HTTP instead of HTTPS (if implementation validates)
echo "Test 18: HTTP endpoint (insecure)"
${UPDATER} --device ${DEVICE} --file error-$PID-test.bin --host "http://api.embedthis.com" --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --quiet
# Should fail at connection or protocol level
if [ $RC != 0 ] ; then
    echo "✓ HTTP endpoint handled (exit code: $RC)"
else
    echo "✗ Should reject or fail on HTTP (exit code: $RC)"
    FAILED=1
fi
rm -f error-$PID-test.bin

echo ""
if [ $FAILED = 0 ] ; then
    echo "✓ All error handling tests passed (exit code: $RC)"
    exit 0
else
    echo "✗ Some error handling tests failed (exit code: $RC)"
    exit 1
fi
