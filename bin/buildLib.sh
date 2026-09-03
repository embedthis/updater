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
#  3. dist/ documentation (CLAUDE.md, README.md, LICENSE.md, doc/, .claude/)
# ---------------------------------------------------------------
sh ~/bin/buildDoc.sh

trace "Complete" "All dist/ files generated successfully"
