@echo off
REM apply-test.bat - Test batch script for Windows update testing
REM
REM This script is called by the updater when applying an update on Windows.
REM It receives the update file path as the first argument.

set IMAGE=%1
if not defined STATUS set STATUS=0

echo apply-test.bat: Processing update from %IMAGE%

REM In a real scenario, this script would:
REM 1. Validate the update package
REM 2. Extract and install the update
REM 3. Restart services or reboot if needed
REM 4. Set STATUS to non-zero on failure

REM For testing, we just echo and exit with STATUS
exit /b %STATUS%