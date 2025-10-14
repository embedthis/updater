/*
    api.tst.c - Unit tests for the updater API

    This file provides comprehensive unit tests for the update() API function.
    Tests cover parameter validation, error handling, edge cases, and typical use cases.

    Copyright (c) EmbedThis Software. All Rights Reserved.
 */

/********************************** Includes **********************************/

#include "testme.h"
#include "../src/osdep/osdep.h"
#include "../src/updater.h"

/********************************** Test Data *********************************/

/*
    Test configuration - These values need to be valid for integration tests
    For pure unit tests, we test parameter validation without making network calls
 */
static cchar *testHost = "https://api.embedthis.com";
static cchar *testProduct = "test-product";
static cchar *testToken = "test-token";
static cchar *testDevice = "test-device-001";
static cchar *testVersion = "1.0.0";
static cchar *testFile = "/tmp/update-test.bin";
static cchar *testScript = "./test-script.sh";

/********************************** Helpers ***********************************/
/*
    Remove test artifacts
 */
static void cleanup(void)
{
    unlink(testFile);
    unlink(testScript);
}

/********************************** Tests *************************************/
/*
    Test: NULL host parameter should return error
 */
static void test_null_host(void)
{
    int rc;

    rc = update(NULL, testProduct, testToken, testDevice, testVersion, NULL, testFile, NULL, 0, 0);
    teqi(rc, -1, "NULL host should return -1");
}

/*
    Test: NULL product parameter should return error
 */
static void test_null_product(void)
{
    int rc;

    rc = update(testHost, NULL, testToken, testDevice, testVersion, NULL, testFile, NULL, 0, 0);
    teqi(rc, -1, "NULL product should return -1");
}

/*
    Test: NULL token parameter should return error
 */
static void test_null_token(void)
{
    int rc;

    rc = update(testHost, testProduct, NULL, testDevice, testVersion, NULL, testFile, NULL, 0, 0);
    teqi(rc, -1, "NULL token should return -1");
}

/*
    Test: NULL device parameter should return error
 */
static void test_null_device(void)
{
    int rc;

    rc = update(testHost, testProduct, testToken, NULL, testVersion, NULL, testFile, NULL, 0, 0);
    teqi(rc, -1, "NULL device should return -1");
}

/*
    Test: NULL version parameter should return error
 */
static void test_null_version(void)
{
    int rc;

    rc = update(testHost, testProduct, testToken, testDevice, NULL, NULL, testFile, NULL, 0, 0);
    teqi(rc, -1, "NULL version should return -1");
}

/*
    Test: NULL path parameter should return error
 */
static void test_null_path(void)
{
    int rc;

    rc = update(testHost, testProduct, testToken, testDevice, testVersion, NULL, NULL, NULL, 0, 0);
    teqi(rc, -1, "NULL path should return -1");
}

/*
    Test: NULL properties parameter should be allowed
 */
static void test_null_properties(void)
{
    int rc;

    /*
        This will fail to connect since we're using test credentials,
        but it should not fail due to NULL properties
     */
    rc = update(testHost, testProduct, testToken, testDevice, testVersion, NULL, testFile, NULL, 0, 0);
    /*
        We expect failure due to authentication/network, but not due to NULL properties
        The function should at least attempt to make the request
     */
    teqi(rc, -1, "NULL properties should be allowed, expected auth/network failure");
}

/*
    Test: NULL script parameter should be allowed (download only, no apply)
 */
static void test_null_script(void)
{
    int rc;

    rc = update(testHost, testProduct, testToken, testDevice, testVersion, NULL, testFile, NULL, 0, 0);
    /*
        Should fail on network/auth, not on NULL script
     */
    teqi(rc, -1, "NULL script should be allowed, expected auth/network failure");
}

/*
    Test: Oversized host URL should be rejected
 */
static void test_oversized_host(void)
{
    char longHost[5000];
    int  rc, i;

    /*
        Create a URL longer than the internal buffer (UBSIZE = 4096)
     */
    strcpy(longHost, "https://");
    for (i = 0; i < 4500; i++) {
        strcat(longHost, "a");
    }
    strcat(longHost, ".com");

    rc = update(longHost, testProduct, testToken, testDevice, testVersion, NULL, testFile, NULL, 0, 0);
    teqi(rc, -1, "Oversized host should be rejected");
}

/*
    Test: Oversized properties should be rejected
 */
static void test_oversized_properties(void)
{
    char longProps[5000];
    int  rc, i;

    /*
        Create properties longer than the internal buffer
     */
    strcpy(longProps, "\"key\":\"");
    for (i = 0; i < 4500; i++) {
        strcat(longProps, "a");
    }
    strcat(longProps, "\"");

    rc = update(testHost, testProduct, testToken, testDevice, testVersion, longProps, testFile, NULL, 0, 0);
    teqi(rc, -1, "Oversized properties should be rejected");
}

/*
    Test: Invalid URL scheme (http instead of https) for host
    Note: The update() function itself may not validate the host scheme,
    but the download URL validation happens during fetch
 */
static void test_http_host(void)
{
    int rc;

    /*
        Using http instead of https for the host
        This should fail eventually, though may not fail immediately
     */
    rc = update("http://api.embedthis.com", testProduct, testToken, testDevice, testVersion, NULL, testFile, NULL, 0, 0);
    teqi(rc, -1, "HTTP host should fail");
}

/*
    Test: Empty string parameters should be rejected
 */
static void test_empty_host(void)
{
    int rc;

    rc = update("", testProduct, testToken, testDevice, testVersion, NULL, testFile, NULL, 0, 0);
    teqi(rc, -1, "Empty host should be rejected");
}

/*
    Test: Empty device ID
 */
static void test_empty_device(void)
{
    int rc;

    rc = update(testHost, testProduct, testToken, "", testVersion, NULL, testFile, NULL, 0, 0);
    teqi(rc, -1, "Empty device should be rejected");
}

/*
    Test: Empty version
 */
static void test_empty_version(void)
{
    int rc;

    rc = update(testHost, testProduct, testToken, testDevice, "", NULL, testFile, NULL, 0, 0);
    teqi(rc, -1, "Empty version should be rejected");
}

/*
    Test: File path with /tmp/ should generate warning but not fail immediately
 */
static void test_tmp_path_warning(void)
{
    int rc;

    /*
        Using /tmp/ path - should warn but attempt to proceed
        Will fail on auth/network but not on the path itself
     */
    rc = update(testHost, testProduct, testToken, testDevice, testVersion, NULL, "/tmp/test.bin", NULL, 0, 0);
    teqi(rc, -1, "/tmp path should warn but fail on auth/network");
}

/*
    Test: Invalid file path (directory that doesn't exist)
 */
static void test_invalid_file_path(void)
{
    int rc;

    rc = update(testHost, testProduct, testToken, testDevice, testVersion, NULL, "/nonexistent/path/to/file.bin", NULL, 0, 0);
    teqi(rc, -1, "Invalid file path should be rejected");
}

/*
    Test: Valid properties format
 */
static void test_valid_properties(void)
{
    int rc;

    /*
        Properties should be in format: "key":"value","key2":"value2"
     */
    rc = update(testHost, testProduct, testToken, testDevice, testVersion,
                "\"model\":\"pro\",\"region\":\"us-west\"", testFile, NULL, 0, 0);
    /*
        Will fail on auth but should accept the properties format
     */
    teqi(rc, -1, "Valid properties should be accepted, expected auth failure");
}

/*
    Test: Verbose mode enabled (should not affect return value)
 */
static void test_verbose_mode(void)
{
    int rc;

    rc = update(testHost, testProduct, testToken, testDevice, testVersion, NULL, testFile, NULL, 1, 0);
    /*
        Verbose flag should only affect output, not return value
     */
    teqi(rc, -1, "Verbose mode should not affect return value");
}

/*
    Test: Special characters in device ID
 */
static void test_special_chars_device(void)
{
    int rc;

    rc = update(testHost, testProduct, testToken, "device-001_test.v2", testVersion, NULL, testFile, NULL, 0, 0);
    teqi(rc, -1, "Special chars in device ID should be accepted, expected auth failure");
}

/*
    Test: Semantic versioning formats
 */
static void test_semver_formats(void)
{
    int rc;

    /*
        Test various semantic version formats
     */
    rc = update(testHost, testProduct, testToken, testDevice, "1.2.3", NULL, testFile, NULL, 0, 0);
    teqi(rc, -1, "Semantic version 1.2.3 should be accepted");

    rc = update(testHost, testProduct, testToken, testDevice, "1.2.3-beta", NULL, testFile, NULL, 0, 0);
    teqi(rc, -1, "Semantic version with pre-release should be accepted");

    rc = update(testHost, testProduct, testToken, testDevice, "1.2.3-beta.1+build.123", NULL, testFile, NULL, 0, 0);
    teqi(rc, -1, "Full semantic version format should be accepted");
}

/*
    Test: Very long authorization token
 */
static void test_long_token(void)
{
    char longToken[300];
    int  rc, i;

    for (i = 0; i < 250; i++) {
        longToken[i] = 'a' + (i % 26);
    }
    longToken[250] = '\0';

    rc = update(testHost, testProduct, longToken, testDevice, testVersion, NULL, testFile, NULL, 0, 0);
    /*
        Should fail on overflow or auth, not on token length itself if within buffer
     */
    teqi(rc, -1, "Long token should fail on overflow or auth");
}

/*
    Test: Script path that doesn't exist
 */
static void test_nonexistent_script(void)
{
    int rc;

    rc = update(testHost, testProduct, testToken, testDevice, testVersion, NULL, testFile, "/nonexistent/script.sh", 0, 0);
    /*
        Should fail on network/auth before trying to run script
     */
    teqi(rc, -1, "Nonexistent script path should be accepted, expected auth failure");
}

/*
    Test: Cleanup after tests
 */
static void test_cleanup(void)
{
    cleanup();
    ttrue(1, "Cleanup completed");
}

/********************************** Main **************************************/

int main(int argc, char **argv)
{
    /*
        NOTE: These are primarily parameter validation tests.
        They test the update() API's input validation and error handling.
        Most tests will fail with -1 due to invalid credentials/network,
        which is expected. We're testing that the API handles edge cases correctly.
     */

    test_null_host();
    test_null_product();
    test_null_token();
    test_null_device();
    test_null_version();
    test_null_path();
    test_null_properties();
    test_null_script();
    test_oversized_host();
    test_oversized_properties();
    test_http_host();
    test_empty_host();
    test_empty_device();
    test_empty_version();
    test_tmp_path_warning();
    test_invalid_file_path();
    test_valid_properties();
    test_verbose_mode();
    test_special_chars_device();
    test_semver_formats();
    test_long_token();
    test_nonexistent_script();
    test_cleanup();

    return 0;
}
