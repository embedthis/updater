# EmbedThis Updater - Change Log

All notable changes to the EmbedThis Updater project are documented in this file in reverse chronological order.

## 2025

### October 17, 2025
- **DEV**: Major code refactoring to improve maintainability and structure
- **DEV**: Refactored `update()` function to use single return point with `do-while(0)` pattern (eliminated goto statements)
- **DEV**: Added WSAStartup/WSACleanup calls for Windows networking initialization in `update()`
- **DEV**: Refactored `fetch()` function from ~148 lines to ~40 lines by extracting 5 helper functions:
  - `parseUrl()` - Extract host and path from URL
  - `connectToHost()` - Create socket and establish TCP connection
  - `sendHttpRequest()` - Format and send HTTP request
  - `readAndValidateResponse()` - Read and validate HTTP response
  - `parseResponseBody()` - Parse Content-Length and body fragment
- **FIX**: Added `--help`, `-h`, and `-?` command-line options with clean help output (no error messages)
- **FIX**: Help requests now exit with code 0 instead of 2, errors still exit with code 2
- **FIX**: Added platform-specific `_POSIX_C_SOURCE 200809L` definition in osdep.h for Linux to enable `strdup()`
- **FIX**: Added `#define strtok_r strtok_s` in osdep.h for Windows POSIX compatibility
- **FIX**: Removed debug printf statement from api.tst.c that was causing issues on Linux
- **FIX**: Added NULL checks for all `strdup()` calls in api.tst.c with proper error handling
- **TEST**: Fixed test command lines to ensure all `--options` appear before properties in 5 test files:
  - javascript.tst.sh (2 fixes)
  - binary-basic.tst.sh (1 fix)
  - shell.tst.sh (1 fix)
  - error-handling.tst.sh (2 fixes)
- **DOC**: Enhanced usage() function documentation in main.c with `isError` parameter details
- **CHORE**: Improved code organization with better function separation and single responsibility principle

### October 16, 2025 (Evening)
- **FIX**: Fixed Windows crash in SSL error handling when `ERR_print_errors_fp(stderr)` was called
- **FIX**: Replaced all `ERR_print_errors_fp(stderr)` calls with safer `printSslErrors()` function
- **FIX**: `printSslErrors()` uses `ERR_error_string_n()` + `fprintf()` instead of direct FILE* access for Windows safety
- **TEST**: Added `quiet == 1` parameter to all C test `update()` calls in api.tst.c (13 instances)
- **TEST**: Added `--quiet` flag to shell test scripts where appropriate (binary-basic, javascript, shell tests)
- **TEST**: Updated windows.tst.win.c tests to use quiet mode and process-unique filenames
- **TEST**: Renamed `test_windows_temp_path()` to `test_windows_path()` with improved path handling

### October 16, 2025 (Afternoon)
- **FIX**: Fixed Windows MSVC compiler warnings for Socket to int conversions in updater.c
- **FIX**: Added explicit (int) casts for close() and SSL_set_fd() calls to handle Windows SOCKET type (UINT_PTR)
- **TEST**: Fixed Windows compatibility in api.tst.c by replacing popen() with getenv() for credential loading
- **TEST**: Removed hardcoded Unix paths (/tmp/) in favor of local directory with getpid() for uniqueness
- **TEST**: Updated test file paths to use process ID for parallel test execution on all platforms
- **TEST**: Credentials now loaded from environment variables (ENDPOINT, PRODUCT, TOKEN, DEVICE, VERSION)
- **DOC**: Documented that Git for Windows (with bash) is a requirement, enabling bash script usage on Windows
- **DOC**: Updated .agent/designs/DESIGN.md with Windows compatibility testing information

### October 15, 2025
- **DEV**: Added `--quiet` option to all three updater implementations (C, JavaScript, Shell)
- **TEST**: Updated all unit tests to use `--quiet` flag instead of `/dev/null` redirection for better error visibility
- **TEST**: Made all unit tests parallel-safe with unique PID-based filenames
- **DEV**: Converted `updater.sh` from environment variables to command-line arguments
- **TEST**: Improved test assertions using specific TestMe APIs (`teqi()`) with descriptive messages
- **CHORE**: Moved `apply.sh` script from `src/` to `test/` directory
- **CHORE**: Simplified credential sourcing in all test files
- **CHORE**: Updated test references to use `updater` from PATH instead of `../src/updater`
- **DOC**: Updated man page with `--quiet` option documentation and examples

### January 14, 2025
- **DEV**: Added comprehensive unit test harness using TestMe framework
- **TEST**: Improved unit test coverage with additional test cases
- **CHORE**: Version bumped to latest stable release
- **CHORE**: Code cleanup and formatting improvements

### January 12, 2025
- **FIX**: Fixed argument validation to properly validate all required parameters
- **FIX**: Corrected Makefile phony targets for proper build behavior
- **DEV**: Added install target to Makefile for system-wide installation

### January 10, 2025
- **DOC**: Created comprehensive man page documentation for command-line interface
- **DOC**: Enhanced README.md with detailed feature descriptions
- **DOC**: Updated DESIGN.md with implementation details and security model

### January 8, 2025
- **SECURITY**: Completed comprehensive security audit
- **FIX**: Improved input validation and error handling
- **DEV**: Added pak publishing support for package distribution

### January 5, 2025
- **TEST**: Revised unit tests for better coverage and reliability
- **DOC**: Improved documentation across README, DESIGN, and CLAUDE.md

## 2024

### December 2024
- **SECURITY**: Completed initial security audit of all implementations
- **TEST**: Revised and expanded unit test suite
- **DOC**: Updated documentation with security features
- **DEV**: Enhanced error handling and validation

### November 2024
- **DEV**: Implemented JavaScript/Node.js alternative implementation
- **DEV**: Added shell script reference implementation
- **DOC**: Created comprehensive design documentation

### October 2024
- **DEV**: Initial C implementation with OpenSSL integration
- **DEV**: Implemented core update workflow (check, download, verify, apply, report)
- **SECURITY**: Added HTTPS enforcement and certificate validation
- **SECURITY**: Implemented SHA-256 checksum verification
- **SECURITY**: Added file security measures (exclusive creation, restricted permissions)

### September 2024
- **INIT**: Project inception and architecture design
- **DOC**: Created initial README and project structure
- **DEV**: Set up build system with Makefile

## Key Features by Version

### Version 2.x (Current)
- ✅ Multiple implementations (C, JavaScript, Shell)
- ✅ Complete Builder service integration
- ✅ Comprehensive security features
- ✅ Full test coverage with TestMe
- ✅ Cross-platform support (Linux, macOS, Windows/WSL)
- ✅ Man page documentation
- ✅ Library and command-line interfaces

### Version 1.x (Legacy)
- Basic C implementation
- Core update functionality
- Initial Builder integration

## Security Enhancements

### 2025
- Certificate validation with system CA bundle
- SNI (Server Name Indication) support
- Hostname verification
- Buffer overflow protection
- Integer overflow protection
- TOCTOU mitigation (Time-of-check to time-of-use)
- Timing-safe checksum comparison (JavaScript)

### 2024
- HTTPS enforcement
- SHA-256 checksum verification
- Content-Length validation
- Timeout protection
- Secure file handling (0600 permissions)
- Exclusive file creation

## Testing Improvements

### 2025
- Comprehensive unit test suite using TestMe
- C, shell, and JavaScript test coverage
- Parallel test execution support
- Automated test harness
- Memory leak detection (valgrind)

### 2024
- Initial manual testing
- Basic integration tests

## Documentation Improvements

### 2025
- Man page for command-line reference
- Comprehensive DESIGN.md with architecture details
- CLAUDE.md for AI-assisted development
- Enhanced README with usage examples
- Security documentation

### 2024
- Initial README
- Basic usage documentation

## Build System Enhancements

### 2025
- Install target for system-wide installation
- Package and cache targets
- Format target for code formatting
- Improved Makefile with phony targets
- Cross-platform build support

### 2024
- Basic Makefile for C compilation
- Debug and release build modes

## Integration Points

### 2025
- Library API for embedding in C/C++ programs
- Command-line utility for standalone use
- Integration paths for Ioto, Appweb, GoAhead

### 2024
- Standalone utility only

## Known Issues

### Current
- No retry logic for transient failures
- No resume support for interrupted downloads
- Single-threaded operation only
- 100MB maximum update size

## Future Considerations

These items are documented but not currently scheduled:

- Retry logic with exponential backoff
- Resume downloads using HTTP Range requests
- Delta updates (binary diff patches)
- Progress reporting callbacks
- Background/daemon mode
- Update scheduling
- Automatic rollback support

## Contributors

- EmbedThis Software Team

## Notes

- All versions follow [Semantic Versioning 2.0](https://semver.org/)
- Security issues are handled privately via security@embedthis.com
- This changelog is suitable for public release on GitHub

---

## Changelog Format

This changelog follows the format:

```
### Date
- **PREFIX**: Description
```

Where PREFIX is one of:
- **DEV**: Development features, refactors
- **FIX**: Bug fixes
- **TEST**: Test changes
- **DOC**: Documentation updates
- **CHORE**: Build system, tooling
- **SECURITY**: Security improvements
- **INIT**: Initial implementation
