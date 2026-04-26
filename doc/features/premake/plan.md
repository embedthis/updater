# Feature Plan: Migrate Updater from MakeMe to Premake5

## Plan Status

**Status:** Completed
**Completed:** February 20, 2026
**Summary:** Migrated build system from MakeMe to premake5, version bumped to 1.2.0
**Remaining:** None

## Context

The R runtime and osdep modules have moved to premake5. The updater still uses the legacy MakeMe build system (main.me, start.me, generated platform makefiles). This migration converts the updater to premake5 for consistency across the EmbedThis ecosystem, following the established patterns in `/Users/mob/dev/ioto/r/`.

## Task Status

| ID | Task | Status | Worktree | Dependencies | Parallel | Completed |
|----|------|--------|----------|--------------|----------|-----------|
| T1 | Core build system conversion | Complete | main | — | T2 | 2026-02-20 |
| T2 | Update README | Complete | main | — | T1 | 2026-02-20 |
| T3 | Build, test, verify, bump version | Complete | main | T1, T2 | — | 2026-02-20 |
| T4 | Release, tag, commit, finalize | Complete | main | T3 | — | 2026-02-20 |

Progress: 4/4 complete

## Scope

**Delivering:**
- premake5.lua build configuration
- New Makefile delegating to premake gmake2
- ME_COM_ defaults in updater.h (not in premake defines)
- buildLib.sh for amalgamated distribution
- Generated project files (gmake2, vs2022, xcode4)
- Cleanup of all MakeMe artifacts
- Updated README with new build instructions
- Version bump, release notes, tag

**Not delivering:**
- MbedTLS support in updater.c (only OpenSSL)
- Changes to updater.c or main.c logic
- Changes to test infrastructure

**Dependencies:**
- premake5 installed for project generation
- Reference: `/Users/mob/dev/ioto/r/Makefile`, `/Users/mob/dev/ioto/r/projects/premake5.lua`

## Tasks

### T1: Core Build System Conversion

**Objective:** Replace MakeMe with premake5 — create premake5.lua, new Makefile, buildLib.sh, update updater.h, delete old files

**Worktree:** `premake-updater-t1`
**Dependencies:** None
**Parallel with:** T2

**Inputs:**
- Reference: `/Users/mob/dev/ioto/r/Makefile` (107 lines)
- Reference: `/Users/mob/dev/ioto/r/projects/premake5.lua` (306 lines)
- Reference: `/Users/mob/dev/ioto/r/bin/buildLib.sh` (44 lines)
- Reference: `/Users/mob/dev/ioto/r/src/r.h` (lines 60-87 for ME_COM_ pattern)
- Template: `/Users/mob/dev/ioto/r/AI/plans/GENERIC-PREMAKE.md`

**Outputs:**
- `projects/premake5.lua` (new)
- `projects/gmake2/` (generated)
- `projects/vs2022/` (generated)
- `projects/xcode/` (generated)
- `Makefile` (replaced)
- `bin/buildLib.sh` (new)
- `src/updater.h` (modified)
- `dist/updaterLib.c`, `dist/updater.h`, `dist/CLAUDE.md` (regenerated)
- Multiple files deleted (see below)

**Implementation Details:**

#### 1. Modify `src/updater.h` — Add ME_COM_ defaults

After `#include "osdep.h"` (line 13), before OpenSSL includes, add:

```c
#ifndef ME_NAME
    #define ME_NAME    "updater"
#endif
#ifndef ME_TITLE
    #define ME_TITLE   "EmbedThis Updater"
#endif

/*
    Components
 */
#ifndef ME_COM_MBEDTLS
    #define ME_COM_MBEDTLS 0
#endif
#ifndef ME_COM_OPENSSL
    #define ME_COM_OPENSSL 1
#endif
#ifndef ME_COM_OSDEP
    #define ME_COM_OSDEP   1
#endif
#ifndef ME_COM_SSL
    #define ME_COM_SSL     1
#endif
#ifndef ME_COM_UPDATER
    #define ME_COM_UPDATER 1
#endif
```

Wrap existing OpenSSL includes in conditional:
```c
#if ME_COM_OPENSSL
    #include <openssl/ssl.h>
    #include <openssl/x509v3.h>
    #include <openssl/err.h>
#endif
```

#### 2. Create `projects/premake5.lua`

Follow r/ pattern but **do NOT put ME_COM_ in defines{}**. Key differences from r/:
- Workspace name: `"updater"`
- Defines: only `ME_VERSION` (no `R_USE_CONFIG`, no ME_COM_*)
- Include dirs: `src/`, `src/osdep/` (no `src/uctx/`)
- Library project: 1 source file (`src/updater.c`)
- Exe project: `"updater-exe"` with `targetname "updater"` (avoids name collision)
- Exe source: `src/main.c`
- No assembly files
- TLS `--tls` option for linking only (not defines)
- TLS include paths at workspace level for OpenSSL header resolution

#### 3. Generate project files

```bash
cd projects && premake5 gmake2 && premake5 vs2022 && premake5 xcode4
```

#### 4. Replace top-level `Makefile`

Follow `/Users/mob/dev/ioto/r/Makefile` exactly. Key targets:
- `build`: delegates to `projects/gmake2` with `config=$(OPTIMIZE)_$(PLATFORM)`
- `clean`: `rm -fr build/`
- `test`: `@bin/test-prep.sh` then `tm test`
- `doc`: exact format specified:
  ```
  doc:
  	cp paks/*/doc/api/* doc/api
  	bun ~/bin/make-doc doc/updater.dox src/updater.h Updater doc/api paks/*/doc/api/*.tags
  ```
- `format`: `uncrustify -q -c .uncrustify --replace --no-backup src/*.{c,h}`
- `package`: `bash bin/buildLib.sh` + copy updater.h and CLAUDE.md to dist/
- `cache`: `build doc package` then `cache`
- `projects`: regenerate premake (developer only)
- Include `.local.mk` if present

#### 5. Create `bin/buildLib.sh`

Amalgamate `src/updater.c` into `dist/updaterLib.c`:
- Wrap in `#include "updater.h"` / `#if ME_COM_UPDATER` / `#endif`
- Strip `#include "updater.h"` from source
- No config.h in distribution

#### 6. Delete MakeMe files

| Category | Files to delete |
|----------|----------------|
| MakeMe configs | `main.me`, `start.me`, `make.bat` |
| Old helpers | `bin/fixProjects` |
| Stub header | `src/me.h` |
| Standalone Makefile | `src/Makefile` |
| Old platform makefiles | `projects/updater-{freebsd,freertos,linux,macosx,vxworks}-default.mk` |
| Old platform configs | `projects/updater-{freebsd,freertos,linux,macosx,vxworks,windows}-default-me.h` |
| Old platform dirs | `projects/updater-{freebsd,freertos,linux,macosx,vxworks}-default/` |
| Old Xcode | `projects/updater-macosx-default.xcodeproj/` |
| Old Windows | `projects/updater-windows-default.sln`, `projects/updater-windows-default.nmake`, `projects/updater-windows-default/` |
| Old NMake helpers | `projects/prep.nmake`, `projects/targets.nmake` |
| Old GUIDs | `projects/.libupdater.guid`, `projects/.prep.guid`, `projects/.updater.guid` |
| Old bat | `projects/windows.bat` (will be regenerated if needed) |

#### 7. Update `.gitignore`

Remove `start.me` entry (file being deleted). Keep `build/` entry.

**Acceptance Criteria:**
- [ ] `src/updater.h` contains ME_COM_ defaults with `#ifndef` guards
- [ ] `src/me.h` deleted
- [ ] `projects/premake5.lua` exists and does NOT contain ME_COM_ in defines
- [ ] `projects/gmake2/Makefile` generated
- [ ] `projects/vs2022/` generated
- [ ] `projects/xcode/` generated
- [ ] New Makefile delegates to `projects/gmake2`
- [ ] `bin/buildLib.sh` creates `dist/updaterLib.c`
- [ ] All MakeMe files deleted (main.me, start.me, make.bat, old project files)
- [ ] No `config.h` in dist/
- [ ] Worktree merged to main without conflicts

**Implementation notes:**
- The `testme.json5` has `-I../build/inc` which is harmless (directory won't exist, flag ignored). The `-I../src` and `-I../src/osdep` flags find the headers. No changes needed.
- `test/api.tst.c` includes `../src/updater.h` directly — no dependency on `me.h` or `build/inc`.

---

### T2: Update README

**Objective:** Update README.md build instructions for premake-based system

**Worktree:** `premake-updater-t2`
**Dependencies:** None
**Parallel with:** T1

**Inputs:**
- Current `/Users/mob/dev/ioto/updater/README.md`
- Reference: `/Users/mob/dev/ioto/r/README.md`

**Outputs:**
- `README.md` (modified building section)

**Implementation Details:**

Replace the "Building" section to document:
- `make` — build using pre-generated premake project files
- `make OPTIMIZE=release` — release build
- `make clean` — remove build artifacts
- `make test` — run unit tests
- `make doc` — generate documentation
- `make format` — format source code
- `make package` — build distribution files
- `make projects` — regenerate premake project files (requires premake5, developer only)
- `SHOW=1 make` — verbose build output
- Windows: open `projects/vs2022/updater.sln` in Visual Studio

Also update the "Files" section to remove references to `main.me`, `start.me`, `me.h`, and add `projects/premake5.lua`, `bin/buildLib.sh`.

**Acceptance Criteria:**
- [ ] README documents all new make targets
- [ ] No references to MakeMe (main.me, me configure, etc.)
- [ ] Documents premake5 for project regeneration
- [ ] Worktree merged to main without conflicts

---

### T3: Build, Test, Verify, Bump Version

**Objective:** Verify the new build system works end-to-end, then bump version

**Worktree:** `premake-updater-t3`
**Dependencies:** T1, T2
**Parallel with:** None

**Inputs:**
- All outputs from T1 and T2 merged to main

**Outputs:**
- Verified build artifacts
- Updated `pak.json` with new version (1.1.4 → 1.2.0)
- Regenerated project files with new version

**Acceptance Criteria:**
- [ ] `make` succeeds — produces `build/bin/libupdater.a` and `build/bin/updater`
- [ ] `make OPTIMIZE=release` succeeds
- [ ] `make clean && make` succeeds
- [ ] `make test` — unit tests pass
- [ ] `make package` — creates `dist/updaterLib.c` and `dist/updater.h`
- [ ] `dist/` does NOT contain config.h
- [ ] `SHOW=1 make` shows build commands
- [ ] `pak.json` version bumped to 1.2.0
- [ ] Project files regenerated with new version
- [ ] Worktree merged to main without conflicts

**Implementation notes:**
- If tests fail, debug in the worktree before merging
- After version bump, re-run `cd projects && premake5 gmake2 && premake5 vs2022 && premake5 xcode4`

---

### T4: Release, Tag, Commit, Finalize

**Objective:** Create release notes, tag, commit all changes, update documentation

**Worktree:** `premake-updater-t4`
**Dependencies:** T3
**Parallel with:** None

**Inputs:**
- All changes merged to main from T1-T3

**Outputs:**
- Release notes at `AI/releases/1.2.0.md`
- Git tag `v1.2.0`
- All changes committed
- Updated `AI/logs/CHANGELOG.md`
- Updated `AI/plans/PLAN.md`

**Acceptance Criteria:**
- [ ] Release notes created for 1.2.0
- [ ] All changes committed with `DEV: migrate build system from MakeMe to premake5`
- [ ] Git tag `v1.2.0` created
- [ ] `AI/logs/CHANGELOG.md` updated
- [ ] `AI/plans/PLAN.md` updated with final status
- [ ] All worktrees cleaned up
- [ ] Worktree merged to main without conflicts

---

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| premake5 project name collision (lib + exe both "updater") | High | Use `"updater-exe"` project name with `targetname "updater"` |
| Test suite references `build/inc` (old MakeMe path) | Low | Tests also have `-I../src` flags; `build/inc` flag is harmless no-op |
| `doc/updater.dox` may not exist | Low | Create if needed, or doc target is for future use |
| Merge conflicts between T1 and T2 | Low | T1 and T2 modify different files (T1: Makefile/premake/src, T2: README) |

## Verification

After all tasks complete:
1. `make clean && make` — clean build succeeds
2. `make OPTIMIZE=release` — release build succeeds
3. `make test` — all tests pass
4. `make package` — dist/ contains updaterLib.c, updater.h, CLAUDE.md (no config.h)
5. `SHOW=1 make` — verbose output works
6. `build/bin/updater -v` — binary runs
7. `git tag` — v1.2.0 exists
