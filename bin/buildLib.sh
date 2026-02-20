#!/bin/bash
#
#   buildLib.sh -- Build the updaterLib.c concatenated source
#
#   Usage: buildLib.sh
#

SRC=src
DST=dist/updaterLib.c

mkdir -p dist

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

echo "Created ${DST}: $(wc -l < "${DST}") lines"

cp src/updater.h dist/updater.h
echo "Copied dist/updater.h"
