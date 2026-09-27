# OSDEP Changelog

## 2026-02-24

- Removed ME_COM_SSL and ME_DEBUG defaults from osdep.h (not osdep concerns)
- Added doc dependency to cache Makefile target
- Fixed documentation errors: ME_OS vs ME_OS_TYPE, Time type description, stale feature references
- Renamed AI/plans/PLAN.md to INDEX.md per conventions

## 2026-02-19 - Release 1.2.0

- Rewritten README with OSdep overview, platform detection, types, and make targets
- Removed validate.c, IDE project files (gmake2, vs2022, xcode), and Premake5 configuration
- Simplified Makefile to utility targets only (header-only module)
- Moved default feature flags to top of osdep.h
- Created doc/releases/release-1.2.0.md

## 2026-02-18

- Updated AI/ documentation (DESIGN.md, CONTEXT.md, CHANGELOG.md, REFERENCES.md)
- Uncommitted: Rename OSDEP_USE_ME to OSDEP_USE_CONFIG
- Uncommitted: Remove AGENTS.md symlink

## 2025-12-17

- Refactored OS detection to use numeric ME_OS_TYPE constants (c7bce57)
- Added 21 OS type constants (ME_OS_UNKNOWN through ME_OS_SOLARIS)
- Detection now uses `ME_OS_TYPE == ME_OS_LINUX` instead of string comparisons

## 2025-12-06

- Added malloc heap stats headers for Linux (`malloc.h`) and macOS (`malloc/malloc.h`) (a0ca527)

## 2025-12-02

- Added ME_HAS_SENDFILE platform detection for zero-copy file transfers (5980f4a)
- Supported on Linux (non-uClibc), macOS, and FreeBSD

## 2025-11-29

- Fixed architecture definitions (6b63531)

## 2025-11-27

- Added Windows on ARM support via `_M_ARM64` compiler detection (c77d1ab)

## 2025-11-19

- Fixed bool type handling (9b47469)

## 2025-11-10

- Include stdbool.h on Linux for proper bool support (e76f109)

## 2025-10-04

- Added stdint.h for all platforms (5309fad)

## 2025-10-03

- Updated and improved Makefiles (5901e1a, 795fe76)

## 2025-10-02

- Fixed Windows compatibility issues (2657a71)
