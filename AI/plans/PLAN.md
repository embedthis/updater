# EmbedThis Updater - Project Plan

## Current Status

The EmbedThis Updater project is in a **stable production state** with three complete implementations (C, JavaScript, Shell) and comprehensive test coverage.

## Recent Completions (2025)

### October 2025
- ✅ **Windows compatibility**: Fixed `api.tst.c` to use `getenv()` instead of `popen()` for reading credentials
- ✅ **Cross-platform paths**: Replaced hardcoded `/tmp/` paths with local directory + `getpid()` for uniqueness
- ✅ **Documentation**: Updated CLAUDE.md and CHANGELOG.md with Windows compatibility notes
- ✅ Added `--quiet` option to suppress stdout while preserving stderr
- ✅ Updated all unit tests to use `--quiet` instead of `/dev/null` redirection
- ✅ Made unit tests parallel-safe with PID-based unique filenames
- ✅ Converted `updater.sh` to command-line arguments (from environment variables)
- ✅ Aligned command-line interface across all three implementations (C, JS, Shell)
- ✅ Improved test assertions with specific TestMe APIs and descriptive messages
- ✅ Moved `apply.sh` to test directory for better organization
- ✅ Simplified credential sourcing in all test files
- ✅ Updated man page with `--quiet` documentation and cron job examples

### January 2025
- ✅ Added comprehensive unit test harness using TestMe
- ✅ Improved unit test coverage with additional test cases
- ✅ Version bumped to latest stable release
- ✅ Code cleanup and formatting improvements
- ✅ Fixed argument validation issues
- ✅ Fixed Makefile phony targets
- ✅ Added install target to Makefile
- ✅ Created man page documentation
- ✅ Enhanced documentation (README, DESIGN)
- ✅ Completed security audit
- ✅ Added pak publishing support

### December 2024
- ✅ Security audit completed
- ✅ Revised unit tests for better coverage
- ✅ Documentation improvements

## Active Work Items

### Maintenance & Stability
- Monitor unit test results and fix any regressions
- Keep dependencies updated (OpenSSL/LibreSSL)
- Review security advisories

### Documentation
- Maintain README with current features
- Keep DESIGN.md synchronized with implementation
- Update CLAUDE.md as needed for AI assistance

## Future Enhancements (Not Currently Scheduled)

These items are potential improvements but not actively planned:

### Priority: Low
- **Retry Logic**: Exponential backoff on transient failures
- **Resume Downloads**: HTTP Range requests for large files
- **Delta Updates**: Binary diff patches for efficiency
- **Progress Reporting**: Download progress callbacks
- **Background Mode**: Daemon mode for continuous checking

### Priority: Very Low
- **Signature Verification**: Digital signatures in addition to checksums
- **Update Scheduling**: Time-based update windows
- **Rollback Support**: Automatic rollback on failed updates

## Development Guidelines

### When Making Changes

1. **Update Tests**: Add or modify unit tests for new features
2. **Run Test Suite**: Use `make test` or `tm` command
3. **Update Documentation**:
   - README.md for user-facing changes
   - doc/DESIGN.md for architectural changes
   - CLAUDE.md for AI assistance context
4. **Format Code**: Run `make format` before committing
5. **Update Changelog**: Add entry to `.agent/logs/CHANGELOG.md`
6. **Follow Commit Conventions**:
   - `FIX:` for bug fixes
   - `DEV:` for features/refactors
   - `TEST:` for test changes
   - `DOC:` for documentation
   - `CHORE:` for build/tooling

### Testing Protocol

Before any release:
1. Run full test suite: `make test`
2. Test C implementation manually with real Builder service
3. Test JavaScript implementation (Node.js and Bun)
4. Verify security features (HTTPS, checksums, validation)
5. Check memory leaks (C implementation with valgrind)

### Security Review Checklist

- [ ] HTTPS enforcement verified
- [ ] Certificate validation tested
- [ ] Checksum verification confirmed
- [ ] Input validation comprehensive
- [ ] File permissions correct (0600)
- [ ] Content-Length limits enforced
- [ ] Timeout protection active
- [ ] No shell injection vulnerabilities

## Integration Points

### Ioto Device Agent
- The Ioto agent includes updater functionality internally
- Changes here may need to be synchronized with Ioto

### Appweb/GoAhead Web Servers
- These projects include updater under `src/updater/`
- Coordinate updates across repositories

### Standalone Usage
- Maintain backward compatibility for standalone users
- Ensure library API remains stable

## Build and Release Process

### Building
```bash
make                  # Build C implementation
make test             # Run test suite
make format           # Format code
make install          # Install to /usr/local/bin
```

### Packaging
```bash
make package          # Create update.tgz
make cache            # Copy to dist/
```

### Publishing
```bash
make publish          # Publish to local registry
make promote          # Promote to public
```

## Dependencies Management

### C Implementation
- **OpenSSL/LibreSSL**: Monitor for security updates
- **Build Tools**: GCC, Make, uncrustify

### JavaScript Implementation
- **Node.js**: Minimum version 18+ (for native fetch)
- **Bun**: Alternative runtime support

### Test Infrastructure
- **TestMe**: Keep tm tool updated
- **Test Config**: `test/testme.json5`

## Known Limitations

1. **No Retry Logic**: Single attempt per check-in
2. **No Resume Support**: Downloads restart from beginning on failure
3. **Single-threaded**: Sequential operation only
4. **100MB Limit**: Maximum update size constraint
5. **Shell Script**: Reference only, not production-ready

## Risk Management

### Low Risk
- OpenSSL API changes (stable API)
- Node.js breaking changes (use conservative features)

### Medium Risk
- Builder service API changes (coordinate with Builder team)
- Platform-specific issues (test on Linux, macOS, Windows/WSL)

### Mitigation Strategies
- Comprehensive test coverage
- Conservative dependency management
- Regular security audits
- Clear documentation

## Communication

### Internal
- Update CLAUDE.md for AI development assistance
- Maintain DESIGN.md for architectural clarity
- Keep this PLAN.md current with status

### External
- README.md for users
- Man page for command-line reference
- GitHub issues for bug reports/feature requests

## Success Metrics

- ✅ Zero known security vulnerabilities
- ✅ 100% test pass rate
- ✅ Clean builds on all supported platforms
- ✅ Comprehensive documentation
- ✅ Stable API for library users

## Next Steps

1. Monitor for security advisories
2. Address any filed issues on GitHub
3. Keep dependencies updated
4. Maintain documentation accuracy
5. Support users with integration questions

## Archive Policy

- Move completed plans to `.agent/archive/plans/` when obsolete
- Keep this PLAN.md focused on current and near-term work
- Maintain historical context in archived documents
