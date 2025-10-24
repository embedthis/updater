# EmbedThis Updater - Design Documentation

## Overview

This directory contains the design documentation for the EmbedThis Updater project. The main architectural and implementation details are documented here to assist Claude Code and developers in understanding and working with the codebase.

## Contents

- [Main Design Document](../../doc/DESIGN.md) - Comprehensive architectural, design, and implementation overview

## Design Principles

The EmbedThis Updater follows these core design principles:

1. **Security First**: All implementations enforce HTTPS, certificate validation, and checksum verification
2. **Simplicity**: Single-purpose tool with minimal dependencies
3. **Portability**: Multiple implementations (C, JavaScript, Shell) for different deployment scenarios
4. **Developer Trust Model**: Assumes developers control and secure the system
5. **Fail-Safe**: Comprehensive validation and error handling at every step

## Architecture Summary

The updater consists of three key implementations:

### C Implementation
- **Purpose**: Production-ready for resource-constrained embedded devices
- **Files**: `main.c`, `updater.c`, `updater.h`
- **Dependencies**: OpenSSL/LibreSSL only
- **Key Features**: Minimal footprint (~10KB), null-tolerant APIs, manual memory management
- **Recent Refactoring** (Oct 17, 2025):
  - `update()` function uses single return point with do-while(0) pattern (no goto statements)
  - `fetch()` function decomposed into 5 focused helper functions for better maintainability
  - Added Windows networking initialization (WSAStartup/WSACleanup)
  - Enhanced cross-platform compatibility with proper feature test macros

### JavaScript Implementation
- **Purpose**: Modern alternative for Node.js/Bun environments
- **Files**: `src/updater.js`
- **Dependencies**: None (uses built-in Node.js modules)
- **Key Features**: Async/await flow, clean error handling, native fetch API

### Shell Script Implementation
- **Purpose**: Reference and documentation only
- **Files**: `src/updater.sh`
- **Dependencies**: curl, jq, openssl
- **Key Features**: Simple to understand, good for testing/development

## Core Workflow

All implementations follow the same five-step process:

1. **Check** - Query Builder service for available updates
2. **Download** - Fetch update package if available
3. **Verify** - Validate SHA-256 checksum
4. **Apply** - Execute custom script to install update
5. **Report** - Send status back to Builder service

## Integration with EmbedThis Builder

The updater integrates with the [EmbedThis Builder](https://www.embedthis.com/builder/) cloud service:

- Updates hosted on AWS S3 with CloudFront CDN
- JavaScript-like distribution policy expressions
- SemVer 2.0 version comparison
- Gradual rollout controls
- Real-time analytics and monitoring

## Key Design Decisions

### Security Model

- **Developer trust**: Developers are responsible for securing the system and validating inputs
- **Network security**: HTTPS with TLS 1.2+, certificate validation, hostname verification
- **Update integrity**: SHA-256 checksums, strict URL validation, content-length enforcement
- **File system security**: Exclusive file creation, restrictive permissions (0600), regular file validation

### Error Handling

- **C**: Return codes (-1 error, 0 success) with stderr messages
- **JavaScript**: Exceptions with try/catch blocks
- **Shell**: Exit codes (0 success, 2 error) with stderr

### Resource Limits

- Maximum update size: 100 MB
- Download timeout: 10 minutes
- Script execution timeout: 5 minutes
- Maximum custom properties: 50

## Code Organization

### Function Decomposition (October 2025 Refactoring)

The C implementation was refactored to improve maintainability through better function decomposition:

#### `update()` Function
- **Pattern**: Single return point using `do-while(0)` idiom
- **Benefits**: Centralized cleanup, no goto statements, easier error handling
- **Resources managed**: fp, downloadUrl, checksum, update, updateVersion, response, WSA initialization

#### `fetch()` Helper Functions
The monolithic `fetch()` function was decomposed into focused helpers:

1. **`parseUrl(char *url, char **hostOut, char **pathOut)`**
   - Extracts host and path components from URL
   - Handles https:// prefix stripping
   - ~15 lines

2. **`connectToHost(cchar *host)`**
   - Creates TCP socket
   - Resolves hostname via DNS
   - Establishes connection to port 443
   - ~30 lines

3. **`sendHttpRequest(Fetch *fp, ...)`**
   - Formats HTTP/1.1 request
   - Sends via TLS connection
   - ~15 lines

4. **`readAndValidateResponse(Fetch *fp, char *response, size_t responseSize)`**
   - Reads initial response
   - Validates HTTP/1.1 protocol
   - Checks status code (200)
   - ~30 lines

5. **`parseResponseBody(Fetch *fp, char *response, ssize bytes)`**
   - Parses Content-Length header
   - Validates content length
   - Handles body fragment
   - ~45 lines

**Result**: Main `fetch()` reduced from ~148 lines to ~40 lines with clear sequential flow

### Platform Abstraction

The `osdep.h` layer provides cross-platform compatibility:

- **Linux**: Defines `_POSIX_C_SOURCE 200809L` for POSIX extensions (strdup, etc.)
- **Windows**: Maps `strtok_r` → `strtok_s`, provides `S_ISREG` macro
- **All platforms**: Consistent type definitions, socket abstractions, error codes

## Testing Strategy

The project includes comprehensive unit tests using TestMe:

- C unit tests: `test/*.tst.c`
- Shell unit tests: `test/*.tst.sh`
- Test configuration: `test/testme.json5`
- Build artifacts: `test/.testme/`

### Windows Compatibility

All tests are Windows-compatible:

- **C tests**: Use `getenv()` to read credentials from environment variables (set by sourcing `creds.sh`)
- **Shell tests**: Run via Git Bash (included with Git for Windows, a required dependency)
- **Test paths**: Use local directory with `getpid()` for unique filenames instead of `/tmp/`
- **Platform-specific tests**: Windows-specific tests use `.win.c` extension (e.g., `windows.tst.win.c`)
- **SSL error handling**: Uses safe `printSslErrors()` function instead of `ERR_print_errors_fp()` to prevent crashes on Windows where FILE* handles may not be properly initialized
- **POSIX compatibility**: `osdep.h` provides `strtok_r` → `strtok_s` mapping for Windows
- **Networking**: Proper WSAStartup/WSACleanup initialization for Windows Sockets API

## Related Documentation

- [README.md](../../README.md) - User-facing documentation
- [CLAUDE.md](../../CLAUDE.md) - Claude Code guidance
- [Main Design Document](../../doc/DESIGN.md) - Detailed technical design

## Maintenance Notes

- Keep this index updated when adding new design documents
- Archive old design documents to `.agent/archive/designs/` when obsolete
- Maintain consistency between implementations
- Update design docs after significant architectural changes
