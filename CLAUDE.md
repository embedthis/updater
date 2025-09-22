# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The EmbedThis Updater is a standalone Over-The-Air (OTA) software update utility and library for IoT devices. It provides multiple implementations:

- **C command-line utility** (`main.c` + `updater.c/h`) - Primary implementation
- **Node.js utility** (`updater.js`) - Alternative JavaScript implementation
- **Shell script** (`updater.sh`) - Sample script implementation
- **C library** (`updater.c/h`) - For integration into other programs

The updater communicates with the EmbedThis Builder cloud service to check for, download, and apply device firmware updates.

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

```bash
make test              # Test C updater with configured parameters
```

### Package Operations
```bash
make package           # Create update.tgz package from src/
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
- **`updater.c/h`** - Main update library with `update()` API
- **`main.c`** - Command-line interface wrapper
- **`apply.sh`** - Script template for applying updates (customize as needed)

### Update Process Flow
1. **Check** - Query Builder service for available updates
2. **Download** - Fetch update package if available
3. **Verify** - Validate checksum of downloaded update
4. **Apply** - Execute configured script to install update
5. **Report** - Send status back to Builder service

### Key Parameters
All implementations require these parameters:
- `--host` - Builder cloud endpoint
- `--product` - Product ID from Builder
- `--token` - CloudAPI access token
- `--device` - Unique device identifier
- `--version` - Current firmware version
- `--file` - Path to save downloaded update
- `--cmd` - Script to apply the update

## Development Notes

### Dependencies
- **C version**: Requires OpenSSL/LibreSSL (`-lssl -lcrypto`)
- **Node.js version**: Uses built-in modules (fetch, crypto, fs)
- **macOS**: Uses Homebrew paths (`/opt/homebrew/include`, `/opt/homebrew/lib`)

### File Structure
- **Root** - C implementation and build files
- **`src/`** - Contains package files and alternative implementations
- **`dist/`** - Distribution files and copies

### Testing Strategy
- Uses live Builder service endpoints for testing
- Separate QA and production environments configured in `.local.mk`
- Test scripts validate full update workflow including download and checksum verification

### Integration Notes
- Library can be embedded in other C/C++ programs via `updater.h`
- Single `update()` function provides complete OTA functionality
- Supports device-specific properties for update policy matching
- The .local.mk file is used locally and is never distributed with the source. 

## Important Notes
- It is assumed that the program is run in a secure environment with a secure file system.
- The user is a developer with control of the system. 

