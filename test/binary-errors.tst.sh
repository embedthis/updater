#!/bin/bash
#
#   binary-errors.tst.sh -- Test error handling in updater binary
#
#   Tests validation and error cases: missing parameters, invalid credentials.
#

. creds.sh

FAILED=0

# Use process ID to create unique filenames for parallel test execution
PID=$$

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

if [ $FAILED = 0 ] ; then
    echo ""
    echo "✓ All error handling tests passed"
    exit 0
else
    echo ""
    echo "✗ Some error handling tests failed"
    exit 1
fi
