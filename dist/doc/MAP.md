# MAP.md — Project Navigation

## System Summary

The EmbedThis Updater is a standalone Over-The-Air (OTA) software update utility and library for IoT devices. It works with the EmbedThis Builder service by default, or with any custom backend implementing the update protocol. The repo provides multiple implementations (C CLI + library, Node.js, shell script) sharing the same Builder API protocol.

**Version**: 1.2.0  **Branch**: main  **State**: Stable, production-ready (premake5 migration complete).

## Feature Index

| Feature | Status | Description |
|---------|--------|-------------|
| [premake/](features/premake/plan.md) | Completed Feb 2026 | Migrated build system from MakeMe to premake5, version 1.2.0 |
| v1.1.4 release prep | Completed Dec 2025 | Version bump, osdep update, project regeneration |
| Windows compatibility | Completed Oct 2025 | Cross-platform paths, getenv() for credentials, Git Bash requirement |
| Quiet mode | Completed Oct 2025 | --quiet option across all implementations, updated tests |
| Shell script CLI alignment | Completed Oct 2025 | Converted updater.sh from env vars to CLI args |
| Test harness | Completed Jan 2025 | TestMe framework, comprehensive C/Shell/JS tests |
| Security audit | Completed Jan 2025 | Full security audit of all implementations |

See [features/INDEX.md](features/INDEX.md) for the canonical feature list.

## Key Documents

| Document | Path | Description |
|----------|------|-------------|
| Product Overview | [overview/product.md](overview/product.md) | High-level product description |
| System Architecture | [architecture/system.md](architecture/system.md) | Architecture, protocol, security model |
| Feature Index | [features/INDEX.md](features/INDEX.md) | All features and plans |
| Issue Tracker | [issues/INDEX.md](issues/INDEX.md) | Active issues |
| Build & Test Procedures | [operations/PROCEDURE.md](operations/PROCEDURE.md) | Operational procedures |
| Changelog | [sessions/CHANGELOG.md](sessions/CHANGELOG.md) | Development history |
| External References | [references/REFERENCES.md](references/REFERENCES.md) | External resources |

## Project Layout

```
updater/
  src/           # Source: updater.c, updater.h, updater.js, updater.sh, apply.sh, osdep.h
  test/          # TestMe unit tests (.tst.c, .tst.sh)
  build/         # Build output (platform-specific)
  projects/      # IDE/platform project files
  bin/           # Scripts and utilities
  doc/           # Project documentation (this directory)
  paks/          # Dependencies (osdep)
  .claude/       # Claude Code settings
```

## Key Source Files

- `src/updater.c` -- Main C implementation (library + update logic)
- `src/updater.h` -- Public API header
- `main.c` -- CLI wrapper (in repo root, not src/)
- `src/updater.js` -- Node.js implementation
- `src/updater.sh` -- Shell script reference implementation
- `Makefile` -- Build system (delegates to premake5)
- `pak.json` -- Package metadata

## Dependencies

- OpenSSL/LibreSSL for TLS and crypto
- osdep (paks/osdep) for OS abstraction
- TestMe (`tm`) for unit testing
- Bun for JavaScript tests (optional)

## Build & Test

```bash
make              # Build C updater
make test         # Run tests
make format       # Format code
make clean        # Clean build
```

## Navigation

- **New to the project?** Start with [overview/product.md](overview/product.md)
- **Looking for a feature?** See [features/INDEX.md](features/INDEX.md)
- **Filing a bug?** See [issues/INDEX.md](issues/INDEX.md)
- **Architecture decisions?** See [architecture/system.md](architecture/system.md)
- **Release history?** See [releases/](releases/) and [sessions/CHANGELOG.md](sessions/CHANGELOG.md)

## Notes

- All three implementations (C, JS, Shell) share the same Builder API protocol.
- Tests require credentials in environment variables (sourced from creds.sh).
- Windows support requires Git for Windows (provides bash).
