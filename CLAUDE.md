# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The EmbedThis Updater is a standalone Over-The-Air (OTA) software update utility and library for IoT devices. It provides multiple implementations:

- **C command-line utility** (`main.c` + `updater.c/h`) - Primary implementation
- **Node.js utility** (`updater.js`) - Alternative JavaScript implementation
- **Shell script** (`updater.sh`) - Sample script implementation
- **C library** (`updater.c/h`) - For integration into other programs

The updater communicates with the EmbedThis Builder cloud service to check for, download, and apply device firmware updates.

## Embedthis Builder

The Embedthis Builder is a cloud service that provides a platform for managing and distributing software updates to IoT devices. It allows you to create and manage updates, and distribute them to your devices over-the-air. [Embedthis Builder](https://admin.embedthis.com)

## Embedthis Builder API

The Embedthis Builder API is a RESTful API that provides a platform for managing and distributing software updates to IoT devices. It allows you to create and manage updates, and distribute them to your devices over-the-air.

See the [Embedthis Builder API](https://www.embedthis.com/doc) documentation for more information.

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
- **Windows**: Requires Git for Windows (includes bash), enabling all shell scripts and tests to run on Windows

### File Structure
- **Root** - C implementation and build files
- **`src/`** - Contains package files and alternative implementations
- **`dist/`** - Distribution files and copies

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

This module maintains structured documentation in the `AI/` directory to assist Claude Code and developers:

- **AI/designs/** - Architectural and design documentation
- **AI/context/** - Current status and progress (CONTEXT.md)
- **AI/plans/** - Implementation plans and roadmaps
- **AI/procedures/** - Testing and development procedures
- **AI/logs/** - Change logs and session activity logs
- **AI/references/** - External documentation and resources
- **AI/releases/** - Version release notes
- **AI/agents/** - Claude sub-agent definitions
- **AI/skills/** - Claude skill definitions
- **AI/prompts/** - Reusable prompts
- **AI/workflows/** - Development workflows
- **AI/commands/** - Custom commands

See `AI/README.md` for detailed information about the documentation structure.

## Additional Resources

- **Parent Project**: See `../CLAUDE.md` for general build commands, testing procedures, and overall EmbedThis architecture
- **API Documentation**: Generated via `make doc` → `doc/index.html`
- **Project Documentation**: See `AI/` directory for designs, plans, procedures, and context
