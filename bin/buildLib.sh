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
#       dist/AI/designs/*.md       Architecture and design documents
#       dist/AI/references/*.md    External references
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
#  5. dist/AI/ (LLM documentation)
# ---------------------------------------------------------------
mkdir -p dist/AI/designs
[ -f AI/designs/DESIGN.md ] && cp AI/designs/DESIGN.md dist/AI/designs/
trace "Copy" "dist/AI/designs/"

if [ -d AI/references ]; then
    mkdir -p dist/AI/references
    for f in AI/references/*.md; do
        [ -f "$f" ] && cp "$f" "dist/AI/references/"
    done
    trace "Copy" "dist/AI/references/"
fi

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
