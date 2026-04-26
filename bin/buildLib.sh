#!/bin/bash
#
#   buildLib.sh -- Build the Updater dist/ files
#
#   Usage: buildLib.sh
#
#   Produces:
#       dist/updaterLib.c          Amalgamated library source with ME_COM_UPDATER guard
#       dist/updater.h             API header (copy)
#       dist/CLAUDE.md             Project documentation (copy)
#       dist/README.md             Project overview (copy)
#       dist/doc/architecture/*.md Architecture and design documents
#       dist/doc/references/*.md   External references
#       dist/.claude/              Claude Code capabilities (skills, commands, etc.)
#

set -e

trace() {
    printf "%12s %s\n" "[$1]" "$2"
}

SRC=src
DST=dist/updaterLib.c

mkdir -p dist

# ---------------------------------------------------------------
#  1. dist/updaterLib.c (amalgamated)
# ---------------------------------------------------------------
cat > "${DST}" << 'ENDOFFILE'
/*
    updaterLib.c -- Updater Library Source

    This file is a catenation of all the source code. Amalgamating into a
    single file makes embedding simpler and the resulting application faster,
    by using compiler optimization within the updater library.

    Prepared by: buildLib.sh
 */

#include "updater.h"

#if ME_COM_UPDATER
ENDOFFILE

printf '\n\n/********* Start of file src/updater.c ************/\n\n' >> "${DST}"
sed '/#include "updater.h"/d' "${SRC}/updater.c" >> "${DST}"

printf '\n#else\nvoid dummyUpdater(){}\n#endif /* ME_COM_UPDATER */\n' >> "${DST}"

trace "Create" "${DST}: $(wc -l < "${DST}") lines"

# ---------------------------------------------------------------
#  2. dist/updater.h (simple copy)
# ---------------------------------------------------------------
cp src/updater.h dist/updater.h
trace "Copy" "dist/updater.h"

# ---------------------------------------------------------------
#  3. dist/CLAUDE.md (simple copy)
# ---------------------------------------------------------------
cp CLAUDE.md dist/CLAUDE.md
trace "Copy" "dist/CLAUDE.md"

# ---------------------------------------------------------------
#  4. dist/README.md
# ---------------------------------------------------------------
cp README.md dist/README.md
trace "Copy" "dist/README.md"

# ---------------------------------------------------------------
#  5. dist/doc/ (LLM documentation)
# ---------------------------------------------------------------
mkdir -p dist/doc

for dir in architecture references operations; do
    if [ -d "doc/${dir}" ] && [ "$(ls -A "doc/${dir}" 2>/dev/null)" ]; then
        rm -rf "dist/doc/${dir}"
        cp -r "doc/${dir}" "dist/doc/${dir}"
        trace "Copy" "dist/doc/${dir}/"
    fi
done

[ -f doc/MAP.md ] && cp doc/MAP.md dist/doc/MAP.md && trace "Copy" "dist/doc/MAP.md"

# ---------------------------------------------------------------
#  6. dist/.claude/ (always created, copy skills/commands/workflows/agents if present)
# ---------------------------------------------------------------
mkdir -p dist/.claude

for dir in skills commands workflows agents; do
    if [ -d ".claude/${dir}" ] && [ "$(ls -A ".claude/${dir}" 2>/dev/null)" ]; then
        cp -r ".claude/${dir}" "dist/.claude/${dir}"
        trace "Copy" "dist/.claude/${dir}/"
    fi
done

trace "Complete" "All dist/ files generated successfully"
