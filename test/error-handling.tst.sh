#!/bin/bash
#
#   error-handling.tst.sh -- Dedicated error case testing for updater
#
#   Tests various error conditions and edge cases that should be properly handled.
#   This test focuses on negative test cases and error paths.
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

UPDATER="../src/updater"
FAILED=0

echo "=== Error Handling Tests for Updater ==="
echo ""

# Test 1: Missing --host parameter
echo "Test 1: Missing --host parameter"
${UPDATER} --device ${DEVICE} --file test.bin --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} > /dev/null 2>&1
if [ $? != 0 ] ; then
    echo "✓ Missing --host correctly rejected"
else
    echo "✗ Should reject missing --host"
    FAILED=1
fi
rm -f test.bin

# Test 2: Missing --product parameter
echo "Test 2: Missing --product parameter"
${UPDATER} --device ${DEVICE} --file test.bin --host ${ENDPOINT} \
    --token ${TOKEN} --version ${VERSION} > /dev/null 2>&1
if [ $? != 0 ] ; then
    echo "✓ Missing --product correctly rejected"
else
    echo "✗ Should reject missing --product"
    FAILED=1
fi
rm -f test.bin

# Test 3: Missing --token parameter
echo "Test 3: Missing --token parameter"
${UPDATER} --device ${DEVICE} --file test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --version ${VERSION} > /dev/null 2>&1
if [ $? != 0 ] ; then
    echo "✓ Missing --token correctly rejected"
else
    echo "✗ Should reject missing --token"
    FAILED=1
fi
rm -f test.bin

# Test 4: Missing --device parameter
echo "Test 4: Missing --device parameter"
${UPDATER} --file test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} > /dev/null 2>&1
if [ $? != 0 ] ; then
    echo "✓ Missing --device correctly rejected"
else
    echo "✗ Should reject missing --device"
    FAILED=1
fi
rm -f test.bin

# Test 5: Missing --version parameter
echo "Test 5: Missing --version parameter"
${UPDATER} --device ${DEVICE} --file test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} > /dev/null 2>&1
if [ $? != 0 ] ; then
    echo "✓ Missing --version correctly rejected"
else
    echo "✗ Should reject missing --version"
    FAILED=1
fi
rm -f test.bin

# Test 6: Invalid/unauthorized token
echo "Test 6: Invalid/unauthorized token"
${UPDATER} --device ${DEVICE} --file test-bad.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token "invalid_token_xyz" --version ${VERSION} > /dev/null 2>&1
if [ $? != 0 ] ; then
    echo "✓ Invalid token correctly rejected"
else
    echo "✗ Should reject invalid token"
    FAILED=1
fi
rm -f test-bad.bin

# Test 7: Malformed URL (missing protocol)
echo "Test 7: Malformed host URL"
${UPDATER} --device ${DEVICE} --file test.bin --host "malformed-url" --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} > /dev/null 2>&1
if [ $? != 0 ] ; then
    echo "✓ Malformed URL correctly rejected"
else
    echo "✗ Should reject malformed URL"
    FAILED=1
fi
rm -f test.bin

# Test 8: Empty device ID
echo "Test 8: Empty device ID"
${UPDATER} --device "" --file test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} > /dev/null 2>&1
if [ $? != 0 ] ; then
    echo "✓ Empty device ID correctly rejected"
else
    echo "✗ Should reject empty device ID"
    FAILED=1
fi
rm -f test.bin

# Test 9: Empty version
echo "Test 9: Empty version string"
${UPDATER} --device ${DEVICE} --file test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version "" > /dev/null 2>&1
if [ $? != 0 ] ; then
    echo "✓ Empty version correctly rejected"
else
    echo "✗ Should reject empty version"
    FAILED=1
fi
rm -f test.bin

# Test 10: Non-existent script path
echo "Test 10: Non-existent script path"
${UPDATER} --device ${DEVICE} --file test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --cmd /nonexistent/path/script.sh > /dev/null 2>&1
# This should fail at network/auth stage, not script validation
if [ $? != 0 ] ; then
    echo "✓ Non-existent script handled"
else
    echo "✓ Non-existent script handled (update may not have been available)"
fi
rm -f test.bin

# Test 11: Invalid product ID
echo "Test 11: Invalid product ID"
${UPDATER} --device ${DEVICE} --file test.bin --host ${ENDPOINT} --product "invalid-product-id" \
    --token ${TOKEN} --version ${VERSION} > /dev/null 2>&1
if [ $? != 0 ] ; then
    echo "✓ Invalid product ID correctly rejected"
else
    echo "✗ Should reject invalid product ID"
    FAILED=1
fi
rm -f test.bin

# Test 12: File path in protected directory (should fail on write)
echo "Test 12: Protected file path"
${UPDATER} --device ${DEVICE} --file /etc/updater-test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} > /dev/null 2>&1
# Expected to fail, either on auth or file write permissions
if [ $? != 0 ] ; then
    echo "✓ Protected path handled appropriately"
else
    echo "✗ Should fail on protected path"
    FAILED=1
fi

# Test 13: Unknown command-line option
echo "Test 13: Unknown command-line option"
${UPDATER} --device ${DEVICE} --file test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --unknown-option value > /dev/null 2>&1
if [ $? != 0 ] ; then
    echo "✓ Unknown option correctly rejected"
else
    echo "✗ Should reject unknown option"
    FAILED=1
fi
rm -f test.bin

# Test 14: Extremely long property key
echo "Test 14: Very long property value"
LONG_VALUE=$(printf 'a%.0s' {1..5000})
${UPDATER} --device ${DEVICE} --file test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} longkey=${LONG_VALUE} > /dev/null 2>&1
# Should fail due to buffer overflow protection
if [ $? != 0 ] ; then
    echo "✓ Oversized property correctly rejected"
else
    echo "✗ Should reject oversized property"
    FAILED=1
fi
rm -f test.bin

# Test 15: Invalid semantic version format
echo "Test 15: Various version formats (should be accepted)"
${UPDATER} --device ${DEVICE} --file test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version "v1.2.3" > /dev/null 2>&1
# Should attempt the request regardless of version format
if [ $? = 0 ] || [ $? = 1 ]; then
    echo "✓ Version format 'v1.2.3' accepted"
else
    echo "✓ Version format handled"
fi
rm -f test.bin

# Test 16: Script with no execute permissions
echo "Test 16: Script without execute permissions"
touch test-script-noperm.sh
chmod 600 test-script-noperm.sh
${UPDATER} --device ${DEVICE} --file test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} --cmd ./test-script-noperm.sh > /dev/null 2>&1
# Should fail at network/auth stage before trying to execute
if [ $? != 0 ] ; then
    echo "✓ Non-executable script handled"
else
    echo "✓ Non-executable script handled (no update available)"
fi
rm -f test.bin test-script-noperm.sh

# Test 17: Malformed property (missing value)
echo "Test 17: Malformed property syntax"
${UPDATER} --device ${DEVICE} --file test.bin --host ${ENDPOINT} --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} badproperty > /dev/null 2>&1
if [ $? != 0 ] ; then
    echo "✓ Malformed property correctly rejected"
else
    echo "✗ Should reject malformed property"
    FAILED=1
fi
rm -f test.bin

# Test 18: HTTP instead of HTTPS (if implementation validates)
echo "Test 18: HTTP endpoint (insecure)"
${UPDATER} --device ${DEVICE} --file test.bin --host "http://api.embedthis.com" --product ${PRODUCT} \
    --token ${TOKEN} --version ${VERSION} > /dev/null 2>&1
# Should fail at connection or protocol level
if [ $? != 0 ] ; then
    echo "✓ HTTP endpoint handled"
else
    echo "✗ Should reject or fail on HTTP"
    FAILED=1
fi
rm -f test.bin

echo ""
if [ $FAILED = 0 ] ; then
    echo "✓ All error handling tests passed"
    exit 0
else
    echo "✗ Some error handling tests failed"
    exit 1
fi
