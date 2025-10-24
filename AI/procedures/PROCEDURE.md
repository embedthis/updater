# EmbedThis Updater - Development Procedures

## Overview

This document contains standard operating procedures for developing, testing, building, and maintaining the EmbedThis Updater project.

## Contents

This is the index of procedure documents:

- [Build Procedures](#build-procedures)
- [Testing Procedures](#testing-procedures)
- [Code Formatting Procedures](#code-formatting-procedures)
- [Git Commit Procedures](#git-commit-procedures)
- [Documentation Procedures](#documentation-procedures)
- [Security Procedures](#security-procedures)
- [Release Procedures](#release-procedures)

---

## Build Procedures

### Building the C Implementation

```bash
# Standard build
cd /Users/mob/c/updater
make                    # or 'make build' or 'make compile'

# Debug build
make OPTIMIZE=debug

# Release build
make OPTIMIZE=release

# Clean build
make clean && make
```

### Build Artifacts
- Executable: `build/darwin-x64-debug/bin/updater` (platform-specific path)
- Object files: `build/darwin-x64-debug/obj/`
- Build metadata: `.makedep`, `.prebuilt`

### Build Requirements
- GCC or compatible C compiler
- OpenSSL or LibreSSL development libraries
- Make (or GNU Make)
- Standard POSIX environment

### Platform-Specific Notes

**macOS**:
```bash
# Uses Homebrew paths by default
# /opt/homebrew/include for headers
# /opt/homebrew/lib for libraries
```

**Linux**:
```bash
# Uses system paths
# /usr/include for headers
# /usr/lib for libraries
```

**Windows**:
```bash
# Use WSL (Windows Subsystem for Linux)
apt install make gcc build-essential libc6-dev openssl libssl-dev

# Git for Windows (with Git Bash) is required for running tests
# Download from: https://git-scm.com/download/win
```

---

## Testing Procedures

### Running Tests

```bash
# Run all tests
make test

# Or from test directory
cd test
tm                      # Run all tests
tm specific.tst.c       # Run specific test
```

### Test Structure
- **Test Files**: `test/*.tst.c`, `test/*.tst.sh`
- **Test Config**: `test/testme.json5`
- **Build Artifacts**: `test/.testme/` (auto-generated)

### Writing New Tests

**C Unit Tests**:
```c
#include "testme.h"
#include "../updater.h"

void testFeature(void) {
    char *result = someFunction();
    ttrue(result != NULL, "Result should not be NULL");
    tstr(result, "expected", "Result should match");
}

int main(void) {
    testFeature();
    return 0;
}
```

**Shell Tests**:
```bash
#!/bin/bash
# test/feature.tst.sh

source testme.sh

# Test code here
if [ condition ]; then
    tpass "Test passed"
else
    tfail "Test failed"
fi
```

### Test Guidelines
- Tests must use `getpid()` for unique filenames (never use hardcoded `/tmp/` paths)
- Tests must be able to run in parallel
- Tests must clean up temporary files
- Tests must use testme.h or testme.sh APIs
- Prefer C tests for C code testing
- C tests must use `getenv()` to read credentials from environment variables (not `popen()`)
- Environment variables: `ENDPOINT`, `PRODUCT`, `TOKEN`, `DEVICE`, `VERSION` (set by sourcing `creds.sh`)

### Test Verification
```bash
# Check test results
tm --verbose           # Verbose output
tm --trace            # Detailed trace

# Check for memory leaks (C tests)
valgrind --leak-check=full ./test/program.tst
```

---

## Code Formatting Procedures

### Automatic Formatting

```bash
# Format all code
make format

# Format specific file
uncrustify -c .uncrustify --replace updater.c
```

### Code Style Standards
- **Indentation**: 4 spaces, no tabs
- **Line Length**: 120 characters maximum
- **Naming**: camelCase for functions and variables
- **Spacing**: One line between functions and code blocks
- **Comments**:
  - Single line: `//`
  - Multi-line: No asterisks on each line

### Before Committing
Always run `make format` before committing code changes.

---

## Git Commit Procedures

### Commit Message Format

```bash
# Feature or refactor
git commit -m "DEV: add retry logic for network failures"

# Bug fix
git commit -m "FIX: correct checksum validation for empty files"

# Test changes
git commit -m "TEST: add unit test for timeout handling"

# Documentation
git commit -m "DOC: update README with new features"

# Build/tooling
git commit -m "CHORE: update Makefile phony targets"
```

### Commit Process

1. **Make changes**: Edit code
2. **Format code**: `make format`
3. **Run tests**: `make test`
4. **Check build**: `make clean && make`
5. **Stage changes**: `git add <files>`
6. **Commit**: `git commit -m "PREFIX: message"`

### Creating Pull Requests

```bash
# Create feature branch
git checkout -b feature/my-feature

# Make changes and commit
git add .
git commit -m "DEV: implement my feature"

# Push to remote
git push -u origin feature/my-feature

# Create PR via GitHub CLI or web interface
gh pr create --title "DEV: implement my feature" --body "Description..."
```

### Commit Guidelines
- **Single purpose**: One logical change per commit
- **Descriptive**: Clear message describing the change
- **Tested**: All tests pass before committing
- **Formatted**: Code is formatted before committing
- **Complete**: Include related documentation updates

---

## Documentation Procedures

### When to Update Documentation

**Always update after**:
- Adding new features
- Changing command-line options
- Modifying APIs
- Changing build process
- Security changes
- Architectural changes

### Documentation Files

1. **README.md**: User-facing documentation
   - Update for new features
   - Update for usage changes
   - Keep examples current

2. **doc/DESIGN.md**: Technical design
   - Update for architectural changes
   - Document design decisions
   - Explain implementation details

3. **CLAUDE.md**: AI assistance context
   - Update for project structure changes
   - Add guidance for new features
   - Document conventions

4. **Man Page**: Command-line reference
   - Update for option changes
   - Keep synchronized with `--help`

5. **.agent/**: Project context
   - Update PLAN.md for current status
   - Update CHANGELOG.md for changes
   - Archive old documentation

### Documentation Testing

```bash
# Build API documentation (if applicable)
make doc

# Check for broken links
# Verify examples work
# Test man page
man ./updater.1
```

---

## Security Procedures

### Security Review Checklist

Before any release:

- [ ] **HTTPS Enforcement**: All URLs validated as HTTPS
- [ ] **Certificate Validation**: TLS certificates properly verified
- [ ] **Checksum Verification**: SHA-256 checksums validated
- [ ] **Input Validation**: All inputs checked and sanitized
- [ ] **File Permissions**: Files created with mode 0600
- [ ] **Content-Length**: Size limits enforced (100MB max)
- [ ] **Timeouts**: Network and script timeouts configured
- [ ] **Shell Injection**: No user input passed to shell
- [ ] **Buffer Overflows**: Bounds checking on all operations
- [ ] **Integer Overflows**: Size calculations validated

### Security Testing

```bash
# Test HTTPS enforcement
./updater --host http://example.com ...  # Should fail

# Test checksum validation
# Modify downloaded file and verify rejection

# Test size limits
# Test with oversized Content-Length

# Test timeout handling
# Test with slow/stalled downloads
```

### Reporting Security Issues

- Do NOT create public issues for security vulnerabilities
- Email security@embedthis.com with details
- Include proof-of-concept if possible
- Allow time for fix before public disclosure

### Security Audit Schedule

- **Quarterly**: Review code for common vulnerabilities
- **Before Major Release**: Full security audit
- **After OpenSSL Update**: Retest TLS implementation

---

## Release Procedures

### Pre-Release Checklist

- [ ] All tests pass: `make test`
- [ ] Code formatted: `make format`
- [ ] Documentation updated
- [ ] Version number bumped
- [ ] CHANGELOG updated
- [ ] Security review completed
- [ ] Manual testing on all platforms
- [ ] No compiler warnings

### Version Numbering

Follow [Semantic Versioning 2.0](https://semver.org/):

- **MAJOR**: Incompatible API changes
- **MINOR**: Backward-compatible new features
- **PATCH**: Backward-compatible bug fixes

### Release Process

1. **Update Version**:
   ```bash
   # Update version in pak.json, Makefile, etc.
   ```

2. **Update Changelog**:
   ```bash
   # Add release notes to .agent/logs/CHANGELOG.md
   ```

3. **Build and Test**:
   ```bash
   make clean
   make
   make test
   ```

4. **Create Tag**:
   ```bash
   git tag -a v1.2.3 -m "Release version 1.2.3"
   git push origin v1.2.3
   ```

5. **Package**:
   ```bash
   make package
   ```

6. **Publish**:
   ```bash
   make publish         # Local registry
   make promote         # Public release
   ```

### Post-Release

- [ ] Verify installation works
- [ ] Update documentation website
- [ ] Announce release (if applicable)
- [ ] Monitor for issues

---

## Troubleshooting Procedures

### Build Failures

**Issue**: OpenSSL not found
```bash
# macOS with Homebrew
brew install openssl
export LDFLAGS="-L/opt/homebrew/lib"
export CPPFLAGS="-I/opt/homebrew/include"

# Linux
sudo apt install libssl-dev
```

**Issue**: Make errors
```bash
# Clean and rebuild
make clean
rm -rf build/
make
```

### Test Failures

**Issue**: Tests fail
```bash
# Run specific test with verbose output
cd test
tm --verbose failing-test.tst.c

# Check for test artifacts
ls -la .testme/

# Verify test configuration
cat testme.json5
```

### Runtime Issues

**Issue**: Certificate validation fails
```bash
# Check CA bundle location
openssl version -d

# Update CA certificates (Linux)
sudo update-ca-certificates

# Update CA certificates (macOS)
# Should be automatic via system keychain
```

---

## Maintenance Procedures

### Regular Maintenance

**Monthly**:
- Check for OpenSSL security updates
- Review and triage GitHub issues
- Run full test suite

**Quarterly**:
- Security audit
- Dependency updates
- Documentation review

**Annually**:
- Review architecture for improvements
- Evaluate new features
- Performance profiling

### Dependency Management

```bash
# Check OpenSSL version
openssl version

# Update OpenSSL (macOS)
brew upgrade openssl

# Update OpenSSL (Linux)
sudo apt update && sudo apt upgrade libssl-dev
```

---

## Archive Policy

When procedures become obsolete:
1. Move to `.agent/archive/procedures/`
2. Add date and reason for archival
3. Update this index to remove reference
4. Keep for historical reference

---

## Additional Resources

- [Main Design Document](../../doc/DESIGN.md)
- [Project Plan](./.agent/plans/PLAN.md)
- [EmbedThis Builder Documentation](https://www.embedthis.com/doc/builder/)
- [TestMe Documentation](~/.local/share/man/man1/tm.1)
