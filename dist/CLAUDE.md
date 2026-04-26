# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The EmbedThis Updater is a standalone Over-The-Air (OTA) software update utility and library for IoT devices. It works with the EmbedThis Builder service by default, or with any custom backend implementing the update protocol. It provides multiple implementations:

- **C command-line utility** (`src/main.c` + `src/updater.c/h`) - Primary implementation
- **Node.js utility** (`src/updater.js`) - Alternative JavaScript implementation
- **Shell script** (`src/updater.sh`) - Sample script implementation
- **C library** (`src/updater.c/h`) - For integration into other programs

The updater communicates with a cloud update service to check for, download, and apply device firmware updates. API endpoint paths are configurable via `--check-path` and `--report-path` CLI options (or `checkPath`/`reportPath` parameters in the C library).

## Embedthis Builder

The Embedthis Builder is a cloud service for managing and distributing software updates to IoT devices over-the-air. It provides a RESTful API for update management and distribution. [Embedthis Builder](https://admin.embedthis.com). See the [Builder API Documentation](https://www.embedthis.com/doc) for more information.

## Build Commands

### Primary Build
```bash
make                    # Build C updater utility
make compile           # Same as make
make build             # Same as make
make clean             # Remove build artifacts
```

### Code Formatting
```bash
make format            # Format code using uncrustify
```

### Testing Commands

Test commands are provided in the `test/` directory.

```bash
make test              # Test C updater with configured parameters
```

### Package Operations
```bash
make package           # Build dist/updaterLib.c amalgamated source
make cache             # Copy files to dist/ directory
```

## Configuration

### Build Configuration
- **`.local.mk`** - Contains environment-specific settings:
  - `VERSION` - Device firmware version
  - `DEVICE` - Unique device identifier
  - `PRODUCT` - Product ID from Builder token list
  - `CLOUDAPI` - CloudAPI access token
  - `HOST` - Builder cloud endpoint URL
  - `PROFILE` - Set to `prod` or leave unset for different environments

### Code Style
- Uses **uncrustify** for code formatting (`.uncrustify` config)
- 4-space indentation, no tabs
- 120-character line limit
- camelCase naming convention

## Architecture

### Core Components
- **`src/updater.c/h`** - Main update library with `update()` API
- **`src/main.c`** - Command-line interface wrapper
- **`src/osdep.h`** - Cross-platform OS abstraction layer

### Update Process Flow
1. **Check** - Query update service for available updates
2. **Download** - Fetch update package if available
3. **Verify** - Validate checksum of downloaded update
4. **Apply** - Execute configured script to install update
5. **Report** - Send status back to update service

### Key Parameters
All implementations require these parameters:
- `--host` - Update service endpoint
- `--product` - Product identifier
- `--token` - API access token
- `--device` - Unique device identifier
- `--version` - Current firmware version
- `--file` - Path to save downloaded update
- `--cmd` - Script to apply the update
- `--check-path` - API path for update check (default: /tok/provision/update)
- `--report-path` - API path for status report (default: /tok/provision/updateReport)
- `--verbose, -v` - Trace execution
- `--quiet, -q` - Suppress all output

## Development Notes

### Dependencies
- **C version**: Requires OpenSSL/LibreSSL (`-lssl -lcrypto`)
- **Node.js version**: Uses built-in modules (fetch, crypto, fs)
- **macOS**: Uses Homebrew paths (`/opt/homebrew/include`, `/opt/homebrew/lib`)
- **Windows**: Requires Git for Windows (includes bash), enabling all shell scripts and tests to run on Windows

### File Structure
- **Root** - Build files (Makefile) and project configuration
- **`src/`** - C implementation, JavaScript, and shell script sources
- **`dist/`** - Distribution files and amalgamated source
- **`test/`** - Unit tests and test fixtures (including sample apply.sh)

### Integration Notes
- Library can be embedded in other C/C++ programs via `updater.h`
- Single `update()` function provides complete OTA functionality
- Supports device-specific properties for update policy matching
- The .local.mk file is used locally and is never distributed with the source. 

## Important Notes
- It is assumed that the program is run in a secure environment with a secure file system.
- The user is a developer with control of the system. 
- Code comments prefixed with "SECURITY Acceptable:" indicate intentional security tradeoffs

## Project Documentation

This module maintains structured documentation in the `doc/` directory to assist Claude Code and developers:

- **doc/overview/** - Product overview and high-level description
- **doc/architecture/** - Architecture, design, and system documentation (`system.md`)
- **doc/features/** - Feature plans index and individual feature directories
- **doc/operations/** - Testing and development procedures
- **doc/issues/** - Issue tracker (`INDEX.md`, `tickets/NNN.md`)
- **doc/sessions/** - Change logs (`CHANGELOG.md`) and session activity logs
- **doc/references/** - External documentation and resources
- **doc/releases/** - Release notes
- **doc/archive/** - Historical architecture, features, sessions, operations

See `doc/MAP.md` for top-level navigation across the project documentation.

## Additional Resources

- **Parent Project**: See `../CLAUDE.md` for general build commands, testing procedures, and overall EmbedThis architecture
- **Design Documentation**: See `doc/architecture/system.md` for architecture and design details
- **API Documentation**: Generated via `make doc` → `doc/api/`
- **Project Documentation**: See `doc/MAP.md` to navigate features, plans, procedures, and history
