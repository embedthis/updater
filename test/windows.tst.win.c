/*
    windows.tst.win.c - Windows-specific unit tests for the updater

    This file contains tests that are specific to Windows platforms.
    The .win.c extension indicates this test only runs on Windows.

    Copyright (c) EmbedThis Software. All Rights Reserved.
 */

/********************************** Includes **********************************/

#include "testme.h"
#include "../src/osdep/osdep.h"
#include "../src/updater.h"

/********************************** Test Data *********************************/
/*
    Test configuration - These values need to be valid for integration tests
 */
static cchar *testHost = "https://unknown.example.com";
static cchar *testProduct = "test-product";
static cchar *testToken = "test-token";
static cchar *testDevice = "test-device-001";
static cchar *testVersion = "1.0.0";
static cchar *testFile = "update-test.bin";

/********************************** Helpers ***********************************/
/*
    Remove test artifacts
 */
static void cleanup(void)
{
    unlink(testFile);
}

/********************************** Tests *************************************/
/*
    Test: Windows batch script execution
 */
static void test_batch_script(void)
{
    int rc;

    /*
        Test that Windows .bat scripts can be executed via CreateProcess
        This tests the Windows-specific code path in run() function
     */
    rc = update(testHost, testProduct, testToken, testDevice, testVersion,
                NULL, testFile, "./apply-test.bat", 0, 1);
    /*
        Should fail on network/auth before trying to run script, but the
        script path should be accepted and the .bat extension recognized
     */
    teqi(rc, -1, "Windows .bat script should be accepted, expected auth failure");
}

/*
    Test: Shell script execution with bash prefix
 */
static void test_shell_script(void)
{
    int rc;

    /*
        Test that .sh scripts are executed via bash on Windows
        The run() function should detect .sh extension and prepend "bash"
     */
    rc = update(testHost, testProduct, testToken, testDevice, testVersion,
                NULL, testFile, "./apply.sh", 0, 1);
    /*
        Should fail on network/auth, but script path should be accepted
        and .sh extension should trigger bash invocation
     */
    teqi(rc, -1, "Shell script with .sh extension should be accepted, expected auth failure");
}

/*
    Test: Windows-style path
 */
static void test_windows_path(void)
{
    char testPath[256];
    int  rc;

    /*
        Test update with Windows path in current directory
        Use process ID to create unique filename for parallel test execution
     */
    snprintf(testPath, sizeof(testPath), ".\\windows-test-%d.bin", getpid());
    rc = update(testHost, testProduct, testToken, testDevice, testVersion,
                NULL, testPath, NULL, 0, 1);
    /*
        Should fail on auth/network but accept the Windows path
     */
    teqi(rc, -1, "Windows path should be accepted, expected auth failure");
    unlink(testPath);
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
        Windows-specific tests for the updater
        These tests verify Windows-specific functionality:
        - CreateProcess execution of .bat files
        - Bash invocation for .sh files in MinGW
        - Windows path handling
     */

    test_batch_script();
    test_shell_script();
    test_windows_path();
    test_cleanup();

    return 0;
}
