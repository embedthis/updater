@echo off
REM
REM   Test prerequisites for running tests on Windows
REM

REM Auto-detect OpenSSL and copy DLLs to build\bin
call "%~dp0openssl-prep.bat"

REM Add build output to PATH
set "PATH=%CD%\build\bin;%PATH%"

REM Add OpenSSL DLLs to PATH
if defined ME_COM_OPENSSL_PATH (
    set "PATH=%ME_COM_OPENSSL_PATH%\bin;%PATH%"
)

REM Check for bash.exe in PATH
where bash.exe >nul 2>&1
if %errorlevel% == 0 goto :finish

if exist "C:\Program Files\Git\bin\bash.exe" (
    set "PATH=C:\Program Files\Git\bin;%PATH%"
    goto :finish
)
if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
    set "PATH=C:\Program Files (x86)\Git\bin;%PATH%"
    goto :finish
)

echo WARNING: bash.exe not found. Please install Git for Windows.
exit /b 1

:finish
